ARG PYTHON_VERSION="PYTHON_VERSION_NOT_SET"
ARG ARCH="ARCH_NOT_SET"

FROM ${ARCH}/python:${PYTHON_VERSION}

RUN apt-get update && \
  apt-get install -y \
    cmake

RUN pip install \
    setuptools \
    numpy \
    bdist-wheel-name \
    wheel>=0.31.0

COPY ./assets/build.sh /build.sh

RUN mkdir /source
RUN mkdir /out
WORKDIR /source

CMD /build.sh