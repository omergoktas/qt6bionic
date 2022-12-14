FROM ubuntu:18.04 as base

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
        python3-pip \
        build-essential \
        libgl1-mesa-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libx11-dev \
        libx11-xcb-dev \
        libxext-dev \
        libxfixes-dev \
        libxi-dev \
        libxrender-dev \
        libxcb1-dev \
        libxcb-glx0-dev \
        libxcb-keysyms1-dev \
        libxcb-image0-dev \
        libxcb-shm0-dev \
        libxcb-icccm4-dev \
        libxcb-sync-dev \
        libxcb-xfixes0-dev \
        libxcb-shape0-dev \
        libxcb-randr0-dev \
        libxcb-render-util0-dev \
        libxcb-util-dev \
        libxcb-xinerama0-dev \
        libxcb-xkb-dev \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        git \
        wget && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip
RUN pip3 install cmake ninja

FROM base as builder

# If set, build that module only, i.e., qtbase
ARG QT_MODULE
ARG QT_MAJ=6.1
ARG QT_MIN=3
ARG QT_VER=${QT_MAJ}.${QT_MIN}

RUN if [ -z "$QT_MODULE" ]; then { \
        wget https://download.qt.io/archive/qt/${QT_MAJ}/${QT_VER}/single/qt-everywhere-src-${QT_VER}.tar.xz; \
        tar -xf qt-everywhere-src-${QT_VER}.tar.xz; \
        mv qt-everywhere-src-${QT_VER} qtworkspace; \
    }; else { \
        wget https://download.qt.io/archive/qt/${QT_MAJ}/${QT_VER}/submodules/${QT_MODULE}-everywhere-src-${QT_VER}.tar.xz; \
        tar -xf ${QT_MODULE}-everywhere-src-${QT_VER}.tar.xz; \
        mv ${QT_MODULE}-everywhere-src-${QT_VER} qtworkspace; \
    }; fi

WORKDIR qtworkspace
RUN mkdir build
WORKDIR build
RUN cmake .. -GNinja
RUN cmake --build . --parallel
RUN cmake --install .

FROM base

WORKDIR /home/qt

COPY --from=builder /usr/local /usr/local

RUN wget https://github.com/omergoktas/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage && chmod a+x linuxdeployqt-continuous-x86_64.AppImage
