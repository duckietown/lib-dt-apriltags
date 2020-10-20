#!/usr/bin/env bash

SOURCE_DIR=/source
OUT_DIR=/out
TEMP_DIR=/tmp

mkdir -p ${TEMP_DIR}/src/
mkdir -p ${TEMP_DIR}/out/

# check source volume
mountpoint -q ${SOURCE_DIR}
if [ $? -ne 0 ]; then
  echo "ERROR: The path '${SOURCE_DIR}' is not a VOLUME. Mount your PIP package to ${SOURCE_DIR}."
  exit 1
fi

# check source volume
mountpoint -q ${OUT_DIR}
if [ $? -ne 0 ]; then
  echo "ERROR: The path '${OUT_DIR}' is not a VOLUME. Output will be lost. Mount it instead."
  exit 2
fi

# from now on, exit if any command fails
set -ex

# copy source to a temp location
cp -R ${SOURCE_DIR}/* ${TEMP_DIR}/src/

# build apriltag library
printf "\n>>> BUILDING APRILTAG\n"
cd ${TEMP_DIR}/src/apriltags
cmake .
make
cd ${TEMP_DIR}/src
SO_FILE=`find ${TEMP_DIR}/src/apriltags | grep 'libapriltag.so$'`
cp ${SO_FILE} ${TEMP_DIR}/src/dt_apriltags/

# build python wheel
printf "\n>>> BUILDING WHEEL\n"
WHEEL_NAME=`python${PYTHON_VERSION} ${TEMP_DIR}/src/setup.py -q bdist_wheel_name`
pip${PYTHON_VERSION} wheel ./ -w ${TEMP_DIR}/out/

WHEEL_PLATFORM='NOT_SET'

if [ ${ARCH} == 'amd64' ]; then
  # turn linux_x86_64 into a manylinux wheel
  WHEEL_PLATFORM='manylinux2010_x86_64'
fi

if [ ${ARCH} == 'arm32v7' ]; then
  # turn 'any' wheel into a linux_armv7l wheel
  WHEEL_PLATFORM='linux_armv7l'
fi

if [ ${ARCH} == 'arm64v8' ]; then
  # turn 'any' wheel into a linux_aarch64 wheel
  WHEEL_PLATFORM='manylinux2014_aarch64'
fi

# move wheel outside the container
NEW_WHEEL_NAME=`python${PYTHON_VERSION} -c "print('-'.join('${WHEEL_NAME}'.split('-')[:3] + ['none', '${WHEEL_PLATFORM}']))"`
mv ${TEMP_DIR}/out/${WHEEL_NAME}.whl ${OUT_DIR}/${NEW_WHEEL_NAME}.whl

# give the host user ownership of the new wheel
USER=`stat -c '%u' ${OUT_DIR}`
GROUP=`stat -c '%g' ${OUT_DIR}`
chown ${USER}:${GROUP} ${OUT_DIR}/${NEW_WHEEL_NAME}.whl
