ROOT=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PYTHON_VERSION="2.7"
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
	twine upload ${ROOT}/dist

clean:
	rm -rf ${ROOT}/dist/*

release:
	make build
	make upload

release-all:
	# Python2
	make release PYTHON_VERSION="2.7"
	# Python3
	make release PYTHON_VERSION="3.6"
