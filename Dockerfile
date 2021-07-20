FROM arm64v8/ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src/app

RUN apt-get update -qq && apt-get install -y \
    cmake \
    libprotobuf-dev \
    protobuf-compiler \
    wget \
    unzip \
    autoconf \
    automake \
    libtool \
    build-essential \
    pkg-config \
    python-setuptools \
    python-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgtk2.0-dev \
    qt5-default \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    libomp-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && apt-get install -y \
    python3 \
    python3-setuptools \
    lbzip2 \
    libavcodec57 \
    libavformat57 \
    libavutil55 \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 libgtk2.0-0 \
    gstreamer1.0-plugins-bad \
    libjpeg8 \
    libpng16-16 \
    libswscale4 \
    libtbb2 \
    libtiff5 \
    libtbb-dev \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ADD nvidia /usr/src/app/nvidia

# Install NVIDIA JetPack SDK & drivers & toolchain
# Removed cublas 10-0 as it should part of cuda-toolkit 10-2
RUN \
    dpkg -i nvidia/deb/cuda-repo-l4t-10-2-local-10.2.89_1.0-1_arm64.deb && \
    apt-key add /var/cuda-repo-10-2-local-10.2.89/7fa2af80.pub && \
    apt-get update && \
    apt-get install -y cuda-cudart-10-2 cuda-toolkit-10-2 && \
    dpkg --remove cuda-repo-l4t-10-2-local-10.2.89 && \
    dpkg -P cuda-repo-l4t-10-2-local-10.2.89 && \
    rm nvidia/deb/cuda-repo-l4t-10-2-local-10.2.89_1.0-1_arm64.deb && \
    dpkg -i nvidia/deb/*.deb && \
    tar xjf nvidia/nvidia_drivers.tbz2 -C / && \
    tar xjf nvidia/config.tbz2 -C / --exclude=etc/hosts --exclude=etc/hostname && \
    tar xjf nvidia/nvgstapps.tbz2 -C / && \
    cp --remove-destination /usr/lib/aarch64-linux-gnu/tegra-egl/nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json && \
    echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf && \
    echo "/usr/lib/aarch64-linux-gnu/tegra-egl" > /etc/ld.so.conf.d/nvidia-tegra-egl.conf && \
    ldconfig 

# Export the CUDA installation permanently
RUN echo "export PATH=/usr/local/cuda-10.2/bin${PATH:+:${PATH}}" >> ~/.bashrc
RUN echo "export LD_LIBRARY_PATH=/usr/local/cuda-10.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >> ~/.bashrc

# Install gstreamer packages, might be too much though
RUN apt-get update -qq && apt-get install -y \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && apt-get install -y \
    python3-numpy \
    && rm -rf /var/lib/apt/lists/*

# Build OpenCV 4.5.2 with Gstreamer
RUN cd ~/ && \
    wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.2.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.5.2.zip && \
    unzip opencv.zip && \
    unzip opencv_contrib.zip && \
    mv opencv-4.5.2 opencv && \
    mv opencv_contrib-4.5.2 opencv_contrib && \
    cd opencv && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D WITH_CUDA=ON \
        -D WITH_CUDNN=ON \
        -D OPENCV_DNN_CUDA=ON \
        -D ENABLE_FAST_MATH=1 \
        -D CUDA_FAST_MATH=1 \
        -D CUDA_ARCH_BIN=5.3 \
        -D WITH_CUBLAS=1 \
        -D WITH_GSTREAMER=ON \
        -D WITH_GSTREAMER_0_10=OFF \
        -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
        -D HAVE_opencv_python3=ON \
        -D PYTHON_EXECUTABLE=/usr/bin/python3 \
        -D BUILD_EXAMPLES=ON ..

RUN cd ~/opencv/build/ && \
    make -j $(($(nproc) + 1)) && \
    make install

RUN cd ~/opencv/build/ && \
    ldconfig

# work dir
WORKDIR /home/nano
