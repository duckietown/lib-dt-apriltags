from xml.dom import minidom

from setuptools import setup

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

setup(
    name='dt_apriltags',
    version=version+POSTFIX,
    author='Aleksandar Petrov',
    author_email='alpetrov@ethz.ch',
    url="https://github.com/duckietown/lib-dt-apriltags",
    install_requires=['numpy'],
    packages=['dt_apriltags'],
    long_description=description,
    include_package_data=True
)
