ARG PYTHON_VERSION="PYTHON_VERSION_NOT_SET"
ARG ARCH="ARCH_NOT_SET"

FROM ${ARCH}/ubuntu:18.04

ARG ARCH
ARG PYTHON_VERSION
ENV QEMU_EXECVE 1

# copy QEMU
COPY ./assets/qemu/${ARCH}/ /usr/bin/

# install python and cmake
RUN apt-get update && \
  apt-get install -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-pip \
    cmake

# install cython (needed by bdist_wheel for numpy)
RUN pip${PYTHON_VERSION} install \
    cython

# install python libraries
RUN pip${PYTHON_VERSION} install \
    setuptools \
    numpy \
    bdist-wheel-name \
    wheel>=0.31.0

# install building script
COPY ./assets/build.sh /build.sh

# prepare environment
ENV ARCH=${ARCH}
ENV PYTHON_VERSION=${PYTHON_VERSION}
RUN mkdir /source
RUN mkdir /out
WORKDIR /source

# define command
CMD /build.sh