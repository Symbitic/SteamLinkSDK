################################################################################
# Copyright (c) 2016, Symbitic
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
################################################################################

# Assert we are running in Travis CI.
if [ ! "${TRAVIS}" == "true" ]
then
    echo "$0 can only be called inside a Travis-CI environment"
    exit 1
fi

# Define CMAKE_BUILD_TYPE if not already given.
if [ -z "${CMAKE_BUILD_TYPE}" ]
then
    CMAKE_BUILD_TYPE="Release"
fi

# Check and setup environment depending on Travis host.
case "${TRAVIS_OS_NAME}" in
linux)
    ;;
osx)
    brew update
    brew outdated cmake || brew upgrade cmake
    brew outdated gmp || brew upgrade gmp
    brew outdated mpfr || brew upgrade mpfr
    brew outdated libmpc || brew upgrade libmpc
    brew outdated isl | brew upgrade isl
    brew install binutils
    brew install ninja
    brew install libelf
    ;;
*)
    echo "Unrecognized OS: ${TRAVIS_OS_NAME}"
    exit 1
    ;;
esac

# Make sure Travis defined all required environment variables.
for var in BUILD_DIR SOURCE_DIR
do
    if [ -z "${!var}" ]
    then
        echo "${var} is not defined"
        exit 1
    fi
done

# Find a usable CMake binary.
CMAKE_EXE=$(which cmake)
if [ ! -e "${CMAKE_EXE}" ]
then
    echo "CMake executable not found"
    exit 1
fi

# Assert that CMake is version 3.0.0 or later.
CMAKE_VERSION=$( ${CMAKE_EXE} --version | head -n 1 | awk -F" " '{print $3}' )
CMAKE_VERSION_MAJOR=$( echo "${CMAKE_VERSION}" | cut -d'.' -f1 )
if [[ ${CMAKE_VERSION_MAJOR} -lt 3 ]]
then
    echo "CMake version 3.0.0 or later is required, "
    echo "found version ${CMAKE_VERSION}."
    exit 1
fi

# Create build directory (if needed).
if [ ! -d "${BUILD_DIR}" ]
then
    mkdir -p "${BUILD_DIR}"
fi

# Run CMake inside an out-of-source build directory.
cd ${BUILD_DIR}

# Configure CMake.
${CMAKE_EXE} \
  -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -DENABLE_TOOLCHAIN=ON \
  ${SOURCE_DIR}