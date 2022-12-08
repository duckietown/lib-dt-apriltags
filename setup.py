from xml.dom import minidom

import subprocess
import os
import sys
import shutil

from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext

POSTFIX = ''

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

class CMakeExtension(Extension):
    def __init__(self, name, cmake_lists_dir='.', **kwa):
        Extension.__init__(self, name, sources=[], **kwa)
        self.cmake_lists_dir = os.path.abspath(cmake_lists_dir)

class CMakeBuildExtension(build_ext):
    def build_extensions(self):
        # Ensure that CMake is present and working
        try:
            subprocess.check_output(['cmake', '--version'])
        except OSError:
            raise RuntimeError('Cannot find CMake executable')

        for ext in self.extensions:
            extdir = os.path.abspath(os.path.dirname(self.get_ext_fullpath(ext.name)))

            if not os.path.exists(self.build_temp):
                os.makedirs(self.build_temp)

            subprocess.check_call(['cmake', '.'], cwd=ext.cmake_lists_dir)
            subprocess.check_call(['make'], cwd=ext.cmake_lists_dir)

            try:
                shutil.copyfile(os.path.join(ext.cmake_lists_dir, "libapriltag.so"), os.path.join(extdir, 'dt_apriltags', "libapriltag.so"))
            except FileNotFoundError:
                shutil.copyfile(os.path.join(ext.cmake_lists_dir, "libapriltag.dylib"), os.path.join(extdir, 'dt_apriltags', "libapriltag.dylib"))


setup(
    name='dt_apriltags',
    version=version+POSTFIX,
    author='Aleksandar Petrov',
    author_email='alpetrov@ethz.ch',
    url="https://github.com/duckietown/lib-dt-apriltags",
    install_requires=['numpy'],
    packages=['dt_apriltags'],
    long_description=description,
    ext_modules = [CMakeExtension("apriltag", "apriltags")],
    cmdclass = {'build_ext': CMakeBuildExtension},
    include_package_data=True
)
