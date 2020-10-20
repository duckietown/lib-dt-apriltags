ROOT=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PYTHON_VERSION=""
ARCH="amd64"

build:
	# create build environment
	docker build \
		-t ${ARCH}/dt_apriltags:wheel-python${$PYTHON_VERSION} \
		--build-arg ARCH="${ARCH}" \
		--build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
		${ROOT}
	# create wheel destination directory
	mkdir -p ${ROOT}/dist
	# build wheel
	docker run \
		-it --rm \
		-v ${ROOT}:/source \
		-v ${ROOT}/dist:/out \
		${ARCH}/dt_apriltags:wheel-python${$PYTHON_VERSION}

upload:
	twine upload ${ROOT}/dist/*

clean:
	rm -rf ${ROOT}/dist/*

release-all:
	# Python2
	make build
	# Python3
	make build PYTHON_VERSION=3
	# Python2
	make build ARCH=arm32v7
	# Python3
	make build ARCH=arm32v7 PYTHON_VERSION=3
	# Python2
	make build ARCH=arm64v8
	# Python3
	make build ARCH=arm64v8 PYTHON_VERSION=3
	# push wheels
	make upload