import os
import pathlib
from xml.dom import minidom

from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext as build_ext_orig

POSTFIX = '.rc0'

def mkdir(path):
    try:
        path.mkdir(parents=True, exist_ok=True)
    except TypeError:
        path.mkdir(parents=True)


class CMakeExtension(Extension):

    def __init__(self, name, sourcedir=list()):
        # don't invoke the original build_ext for this special extension
        Extension.__init__(self, name, sources=[])
        self.sourcedir = os.path.abspath(sourcedir)


class build_ext(build_ext_orig):

    def run(self):
        for ext in self.extensions:
            self.build_cmake(ext)
        build_ext_orig.run(self)

    def build_cmake(self, ext):
        cwd = pathlib.Path().absolute()

        # these dirs will be created in build_py, so if you don't have
        # any python sources to bundle, the dirs will be missing
        build_lib = pathlib.Path(self.build_lib)
        print('build_lib', build_lib)
        build_temp = pathlib.Path(self.build_temp)
        print('build_temp', build_temp)
        mkdir(build_temp)
        extdir = pathlib.Path(self.get_ext_fullpath(ext.name))
        print('extdir', extdir)
        mkdir(extdir)
        #
        # # example of cmake args
        # config = 'Debug' if self.debug else 'Release'
        # cmake_args = [
        #     '-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=' + str(extdir.parent.absolute()),
        #     '-DCMAKE_BUILD_TYPE=' + config
        # ]
        #
        # # example of build args
        # build_args = [
        #     '--config', config,
        #     '--', '-j4'
        # ]

        cmake_args=[]
        build_args=[]

        os.chdir(str(build_temp))
        self.spawn(['cmake', str(cwd)+'/apriltags'] + cmake_args)
        if not self.dry_run:
            self.spawn(['cmake', '--build', '.'] + build_args)
            self.spawn(['cp', 'lib/libapriltag.so', str(cwd/build_lib)+'/dt_apriltags/libapriltag.so'])
        os.chdir(str(cwd))

version = minidom.parse('apriltags/package.xml').getElementsByTagName("version")[0].childNodes[0].data

description = """
dt_apriltags: Python bindings for the Apriltags library
=======================================================

These are Python bindings for the
`Apriltags <https://github.com/AprilRobotics/apriltags>`__ library
developed by `AprilRobotics <https://april.eecs.umich.edu/>`__. Inspired
by the `Apriltags2 bindings <https://github.com/swatbotics/apriltag>`__
by `Matt Zucker <https://github.com/mzucker>`__.

The original library is published with a `BSD 2-Clause
license <https://github.com/AprilRobotics/apriltag/blob/master/LICENSE.md>`__.

You can find more information on how to use this library in the
GitHub `repository <https://github.com/duckietown/dt-apriltags>`_.

"""

setup(
    name='dt_apriltags',
    version=version+POSTFIX,
    author='Aleksandar Petrov',
    author_email='alpetrov@ethz.ch',
    url="https://github.com/duckietown/dt-apriltags",
    install_requires=['numpy','pathlib'],
    packages=['dt_apriltags'],
    long_description=description,
    ext_modules=[CMakeExtension('apriltags', sourcedir='dt_apriltags')],
    cmdclass={
        'build_ext': build_ext,
    }
)