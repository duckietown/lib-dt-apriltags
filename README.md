# lib-dt-apriltags: Python bindings for the Apriltags library

These are Python bindings for the [Apriltags 3](https://github.com/AprilRobotics/apriltags) library developed by [AprilRobotics](https://april.eecs.umich.edu/). Inspired by the [Apriltags2 bindings](https://github.com/swatbotics/apriltag) by [Matt Zucker](https://github.com/mzucker).

The original library is published with a [BSD 2-Clause license](https://github.com/AprilRobotics/apriltag/blob/master/LICENSE.md). 

## Installation

### The easy way
You can install using `pip` (or `pip3` for Python 3):
```
pip install dt-apriltags
```

And if you want a particular release, add it like this:
```
pip install dt-apriltags@v3.1.1
```

### Build it yourself

Clone this repository and navigate in it. Then initialize the Apriltags submodule:
```
$ git submodule init
$ git submodule update
```

Build the Apriltags C library and embed the newly-built library into the pip wheel.
```
$ make build
```

The new wheel will be available in the directory `dist/`.
You can now install the wheel
```
pip install dt_apriltags-VERSION-pyPYMAJOR-none-ARCH.whl
```
NOTE: based on the current `VERSION` of this library and the version of Python used `PYMAJOR`, together with the architecture of your CPU `ARCH`, the filename above varies.


#### Build for Python 3

This library supports building wheels for Python `2` and `3`. Python 2 will be used by default.
Use the following command to build for Python 3.
```
make build PYTHON_VERSION=3
```


#### Build for different architecture

This library supports building wheels for the CPU architectures `amd64`, `arm32v7`, and `arm64v8`. Default architecture is `amd64`.
When building wheels for ARM architectures, QEMU will be used to emulate the target CPU.
Use the following command to build for `arm32v7` architecture.
```
make build ARCH=arm32v7
```


## Release wheels

All the wheels built inside `dist/` can be released (pushed to Pypi.org) by running the command
```
make upload
```


### Release all

Use the following command to build and release wheels for Python 2 and 3 and CPU architecture `amd64` and `arm32v7`.
```
make release-all
```


## Usage

Some examples of usage can be seen in the `test.py` file.
The `Detector` class is a wrapper around the Apriltags functionality. You can initialize it as following:

```
at_detector = Detector(searchpath=['apriltags'],
                       families='tag36h11',
                       nthreads=1,
                       quad_decimate=1.0,
                       quad_sigma=0.0,
                       refine_edges=1,
                       decode_sharpening=0.25,
                       debug=0)
```

The options are:

| **Option**        	| **Default**   	| **Explanation**                                                                                                                                                                                                                                                                                                                  	|
|-------------------	|---------------	|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| families          	| 'tag36h11'    	| Tag families, separated with a space                                                                                                                                                                                                                                                                                             	|
| nthreads          	| 1             	| Number of threads                                                                                                                                                                                                                                                                                                                	|
| max_hamming    	    | 2           	    | 	The max number of bits that are allowed to be flipped to generate a successful tag detection. Can help decrease false negatives  when noise causes some data bits to be read incorrectly, but can also increase false positives.                                          	|
| quad_decimate     	| 2.0           	| Detection of quads can be done on a lower-resolution image, improving speed at a cost of pose accuracy and a slight decrease in detection rate. Decoding the binary payload is still done at full resolution. Set this to 1.0 to use the full resolution.                                                                        	|
| quad_sigma        	| 0.0           	| What Gaussian blur should be applied to the segmented image. Parameter is the standard deviation in pixels. Very noisy images benefit from non-zero values (e.g. 0.8)                                                                                                                                                            	|
| refine_edges      	| 1             	| When non-zero, the edges of the each quad are adjusted to "snap to" strong gradients nearby. This is useful when decimation is employed, as it can increase the quality of the initial quad estimate substantially. Generally recommended to be on (1). Very computationally inexpensive. Option is ignored if quad_decimate = 1 	|
| decode_sharpening 	| 0.25          	| How much sharpening should be done to decoded images? This can help decode small tags but may or may not help in odd lighting conditions or low light conditions                                                                                                                                                                 	|
| searchpath        	| ['apriltags'] 	| Where to look for the Apriltag 3 library, must be a list                                                                                                                                                                                                                                                                         	|
| debug             	| 0             	| If 1, will save debug images. Runs very slow  

Detection of tags in images is done by running the `detect` method of the detector:

```
tags = at_detector.detect(img, estimate_tag_pose=False, camera_params=None, tag_size=None)
```

If you also want to extract the tag pose, `estimate_tag_pose` should be set to `True` and `camera_params` (`[fx, fy, cx, cy]`) and `tag_size` (in meters) should be supplied. The `detect` method returns a list of `Detection` objects each having the following attributes (note that the ones with an asterisks are computed only if `estimate_tag_pose=True`):

| **Attribute**   	| **Explanation**                                                                                                                                                                                                                                                                                                                                                                                            	|
|-----------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| tag_family      	| The family of the tag.                                                                                                                                                                                                                                                                                                                                                                                     	|
| tag_id          	| The decoded ID of the tag.                                                                                                                                                                                                                                                                                                                                                                                 	|
| hamming         	| How many error bits were corrected? Note: accepting large numbers of corrected errors leads to greatly increased false positive rates. NOTE: As of this implementation, the detector cannot detect tags with a Hamming distance greater than 3.                                                                                                                                                            	|
| decision_margin 	| A measure of the quality of the binary decoding process: the average difference between the intensity of a data bit versus the decision threshold. Higher numbers roughly indicate better decodes. This is a reasonable measure of detection accuracy only for very small tags-- not effective for larger tags (where we could have sampled anywhere within a bit cell and still gotten a good detection.) 	|
| homography      	| The 3x3 homography matrix describing the projection from an "ideal" tag (with corners at (-1,1), (1,1), (1,-1), and (-1, -1)) to pixels in the image.                                                                                                             	|
| center          	| The center of the detection in image pixel coordinates.                                                                                                                                                                                                                                                                                                                                                    	|
| corners         	| The corners of the tag in image pixel coordinates. These always wrap counter-clock wise around the tag.                                                                                                                                                                                                                                                                                                    	|
| pose_R*         	| Rotation matrix of the pose estimate.                                                                                                                                                                                                                                                                                                                                                                      	|
| pose_t*         	| Translation of the pose estimate.                                                                                                                                                                                                                                                                                                                                                                          	|
| pose_err*       	| Object-space error of the estimation.                                                                                                                                                                                                                                                                                                                                                                      	|

## Custom layouts

If you want to use a custom layout, you need to create the C source and header files for it and then build the library again. Then use the new `libapriltag.so` library. You can find more information on the original [Apriltags repository](https://github.com/AprilRobotics/apriltags).


## Developer notes

The wheel is built inside a Docker container. The Dockerfile in the root of this repository is a template for the build environment. The build environment is based on `ubuntu:18.04` and the correct version of python is installed on the fly.
The `make build` command will create the build environment if it does not exist before building the wheel.

Once the build environment (Docker image) is ready, a Docker container is launched with the following configuration:
- the root of this repository mounted to `/source`;
- the directory `dist/` is mounted as destination directory under `/out`;

The building script from `assets/build.sh` will be executed inside the container. The build steps are:
- copy source code from `/source` to a temp location (inside the container)
- build apriltag library from submodule `apriltags/` (will produce a .so library file)
- build python wheel (the .so library is embedded as `package_data`)
- copy wheel file to `/out` (will pop up in `dist/` outside the container)
