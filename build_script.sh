#!/usr/bin/env bash

# NOTE: by default uploads to https://test.pypi.org/simple/. In order to upload to PyPI, set the env var FINAL=1

# exit when any command fails
set -e

printf "\n>>> BUILDING FOR PYTHON 2\n"
python setup.py sdist bdist_wheel
printf "\n>>> CHECKING IF THE README IS COMPLIANT\n"
python -m twine check dist/*

if [ -z "$FINAL" ]
then
    printf "\n>>> PUSHING TO THE TEST REPOSITORY\n"
    python -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*
else
    printf "\n>>> PUSHING TO THE OFFICIAL REPOSITORY\n"
    python -m twine upload  dist/*
fi

printf "---------------------------------------------------------------"
printf "\n>>> BUILDING FOR PYTHON 3\n"
python3 setup.py sdist bdist_wheel
printf "\n>>> CHECKING IF THE README IS COMPLIANT\n"
python3 -m twine check dist/*

if [ -z "$FINAL" ]
then
    printf "\n>>> PUSHING TO THE TEST REPOSITORY\n"
    python3 -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*
else
    printf "\n>>> PUSHING TO THE OFFICIAL REPOSITORY\n"
    python3 -m twine upload  dist/*
fi