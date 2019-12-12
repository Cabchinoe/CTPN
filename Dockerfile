FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu16.04
MAINTAINER cabchinoe@gmail.com

RUN apt update && apt install -y vim cmake make g++ unzip \
        python2.7 python2.7-dev \
        python-pip wget lrzsz

RUN pip install pip -U
RUN pip install numpy opencv-contrib-python==3.4.4.19 Pillow lmdb scikit-image protobuf cython PyYaml --no-cache-dir

RUN apt -y remove x264 libx264-dev
RUN apt -y install build-essential checkinstall  pkg-config yasm git gfortran \
        libjpeg8-dev libjasper-dev libpng12-dev \
        libtiff5-dev libtiff-dev \
        libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev \
        libxine2-dev libv4l-dev
RUN cd /usr/include/linux && ln -s -f ../libv4l1-videodev.h videodev.h

RUN apt -y install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev \
        libgtk2.0-dev libtbb-dev qt5-default \
        libatlas-base-dev \
        libfaac-dev libmp3lame-dev libtheora-dev \
        libvorbis-dev libxvidcore-dev \
        libopencore-amrnb-dev libopencore-amrwb-dev \
        libavresample-dev \
        x264 v4l-utils \
        libprotobuf-dev protobuf-compiler \
        libgoogle-glog-dev libgflags-dev \
        libgphoto2-dev libeigen3-dev libhdf5-dev doxygen liblmdb-dev libleveldb-dev libsnappy-dev libboost-all-dev
WORKDIR  /home
RUN wget  https://github.com/opencv/opencv_contrib/archive/3.4.4.zip -O opencv_contrib_3.4.4.zip && unzip opencv_contrib_3.4.4.zip
RUN wget https://github.com/opencv/opencv/archive/3.4.4.zip -O opencv-3.4.4.zip && unzip opencv-3.4.4.zip
RUN cd opencv-3.4.4 && mkdir build && cd build
WORKDIR  /home/opencv-3.4.4/build
RUN cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.4.4/modules -DWITH_CUDA=ON -DWITH_CUBLAS=ON -DDCU
DA_NVCC_FLAGS="-D_FORCE_INLINES" -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -DCUDA_ARCH_BIN="6.1 7.0 7.5" -DOPENCV_ENABLE_NONFREE:BOOL=ON
RUN make -j8 && make install  && make clean && cd /usr/local/python/ && python setup.py develop
WORKDIR  /home
RUN git clone https://github.com/Cabchinoe/CTPN.git --recursive
RUN cd CTPN/caffe && mkdir build && cd build && cmake .. -DCUDA_ARCH_NAME="Pascal Turing Volta"\
        && make pycaffe -j8 && make all -j8
