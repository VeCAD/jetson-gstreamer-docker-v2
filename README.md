Jetson Nano Docker with Gstreamer v2
====================================

Refering to [v1](https://github.com/VeCAD/jetson-gstreamer-docker), after fiddling around trying to 
restart the nvargus-daemon inside the container, I felt this wasn't really a clean solution, so I decided 
to look around for other options of running the nvargus-daemon isolated from the host system.

I came across this repo https://github.com/zrzka/nanny-bot that copies and installs the necessary L4T files 
into the container, installs them and runs the container without the `nvidia-runtime` needed to share CUDA 
ecosystem of the host. 

Following the guide in the Readme, I managed to get the following files installed in the container using
Jetpack 4.4.1 (L4T 32.4.4). In my case, this was the L4T files required as I was using a later version 32.4.4.

```
nvidia/
├── deb
│   ├── cuda-repo-l4t-10-2-local-10.2.89_1.0-1_arm64.deb
│   ├── graphsurgeon-tf_7.1.3-1+cuda10.2_arm64.deb
│   ├── libcudnn8_8.0.0.180-1+cuda10.2_arm64.deb
│   ├── libcudnn8-dev_8.0.0.180-1+cuda10.2_arm64.deb
│   ├── libcudnn8-doc_8.0.0.180-1+cuda10.2_arm64.deb
│   ├── libnvinfer7_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvinfer-bin_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvinfer-dev_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvinfer-doc_7.1.3-1+cuda10.2_all.deb
│   ├── libnvinfer-plugin7_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvinfer-plugin-dev_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvinfer-samples_7.1.3-1+cuda10.2_all.deb
│   ├── libnvonnxparsers7_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvonnxparsers-dev_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvparsers7_7.1.3-1+cuda10.2_arm64.deb
│   ├── libnvparsers-dev_7.1.3-1+cuda10.2_arm64.deb
│   ├── libvisionworks-repo_1.6.0.501_arm64.deb
│   ├── libvisionworks-sfm-repo_0.90.4.501_arm64.deb
│   ├── libvisionworks-tracking-repo_0.88.2.501_arm64.deb
│   ├── OpenCV-4.1.1-2-gd5a58aa75-aarch64-dev.deb
│   ├── OpenCV-4.1.1-2-gd5a58aa75-aarch64-libs.deb
│   ├── OpenCV-4.1.1-2-gd5a58aa75-aarch64-licenses.deb
│   ├── OpenCV-4.1.1-2-gd5a58aa75-aarch64-python.deb
│   ├── OpenCV-4.1.1-2-gd5a58aa75-aarch64-samples.deb
│   ├── python3-libnvinfer_7.1.3-1+cuda10.2_arm64.deb
│   ├── python3-libnvinfer-dev_7.1.3-1+cuda10.2_arm64.deb
│   ├── tensorrt_7.1.3.0-1+cuda10.2_arm64.deb
│   ├── uff-converter-tf_7.1.3-1+cuda10.2_arm64.deb 
├── nvgstapps.tbz2
└── nvidia_drivers.tbz2
├── config.tbz2
```
