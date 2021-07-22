import os
import cv2
# refer https://forums.developer.nvidia.com/t/how-to-close-gstreamer-pipeline-in-python/74753/22
# for additional appsink parameters "max-buffers=1 drop=True"
# to address camera getting disconnected after awhile
# the original pipeline is from JetsonHacksNano github
# https://github.com/JetsonHacksNano/CSI-Camera
def gstreamer_pipeline(
    capture_width=1280,
    capture_height=720,
    display_width=1280,
    display_height=720,
    framerate=60,
    flip_method=0
    ):
    return (
    "nvarguscamerasrc ! "
    "video/x-raw(memory:NVMM), "
    "width=(int)%d, height=(int)%d, "
    "format=(string)NV12, framerate=(fraction)%d/1 ! "
    "nvvidconv flip-method=%d ! "
    "video/x-raw, width=(int)%d, height=(int)%d, format=(string)BGRx ! "
    "videoconvert ! "
    "video/x-raw, format=(string)BGR ! appsink drop=True "
    % (
        capture_width,
        capture_height,
        framerate,
        flip_method,
        display_width,
        display_height
    )
    )

def show_camera():
    # start argus daemon
    os.system('nvargus-daemon &')
    print(gstreamer_pipeline(flip_method=0))
    cap = cv2.VideoCapture(gstreamer_pipeline(flip_method=0), cv2.CAP_GSTREAMER)
    while(cap.isOpened()):
        ret, frame = cap.read()
        if ret:
            cv2.imshow("Image", frame)
        else:
            print('no video')
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    show_camera()
