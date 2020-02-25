# dt-apriltags: Python bindings for the Apriltags library

These are Python bindings for the [Apriltags](https://github.com/AprilRobotics/apriltags) library developed by [AprilRobotics](https://april.eecs.umich.edu/). Inspired by the [Apriltags2 bindings](https://github.com/swatbotics/apriltag) by [Matt Zucker](https://github.com/mzucker).

The original library is published with a [BSD 2-Clause license](https://github.com/AprilRobotics/apriltag/blob/master/LICENSE.md). 

## Installation

### The easy way
You can install using `pip`:
```
pip install dt-apriltags
```

## Build it yourself

Clone this repository and navigate in it. Then initialize the Apriltags submodule:

```
$ git submodule init
$ git submodule update
```
Build the Apriltags C library. Keep in mind you need to have OpenCV installed beforehand.

```
$ cd apriltags
$ cmake .
$ make
```
If building Apriltags was successful, you should be able to run the demo.

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
| hamming         	| How many error bits were corrected? Note: accepting large numbers of corrected errors leads to greatly increased false positive rates. NOTE: As of this implementation, the detector cannot detect tags with a Hamming distance greater than 2.                                                                                                                                                            	|
| decision_margin 	| A measure of the quality of the binary decoding process: the average difference between the intensity of a data bit versus the decision threshold. Higher numbers roughly indicate better decodes. This is a reasonable measure of detection accuracy only for very small tags-- not effective for larger tags (where we could have sampled anywhere within a bit cell and still gotten a good detection.) 	|
| homography      	| The 3x3 homography matrix describing the projection from an "ideal" tag (with corners at (-1,1), (1,1), (1,-1), and (-1, -1)) to pixels in the image.                                                                                                             	|
| center          	| The center of the detection in image pixel coordinates.                                                                                                                                                                                                                                                                                                                                                    	|
| corners         	| The corners of the tag in image pixel coordinates. These always wrap counter-clock wise around the tag.                                                                                                                                                                                                                                                                                                    	|
| pose_R*         	| Rotation matrix of the pose estimate.                                                                                                                                                                                                                                                                                                                                                                      	|
| pose_t*         	| Translation of the pose estimate.                                                                                                                                                                                                                                                                                                                                                                          	|
| pose_err*       	| Object-space error of the estimation.                                                                                                                                                                                                                                                                                                                                                                      	|

## Custom layouts
If you want to use a custom layout, you need to create the C source and header files for it and then build the library again. Then use the new `libapriltag.so` library. You can find more information on the original [Apriltags repository](https://github.com/AprilRobotics/apriltags).
