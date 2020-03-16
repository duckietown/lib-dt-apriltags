FROM ubuntu:18.04

RUN apt-get update && \
  apt-get install -y python python3 python-pip python3-pip cmake
RUN  pip install setuptools pathlib twine>=1.14.0 wheel>=0.31.0 && \
  pip3 install setuptools twine>=1.14.0

COPY . /dt-apriltags

WORKDIR /dt-apriltags

CMD ./build_script.sh