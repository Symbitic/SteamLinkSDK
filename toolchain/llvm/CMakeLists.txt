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

include(ExternalProject)
include(ProcessorCount)

# Set the number of parallel jobs to use.
ProcessorCount(LLVM_PARALLEL_COMPILE_JOBS)
ProcessorCount(LLVM_PARALLEL_LINK_JOBS)

# LLVM settings
set(LLVM_URL "http://llvm.org/releases/3.7.1/llvm-3.7.1.src.tar.xz")
set(LLVM_HASH "bf8b3a2c79e61212c5409041dfdbd319")
set(LLVM_PATCH "${PATCH_DIR}/llvm-3.7.1.patch")

# Require GNU Patch for patching downloaded sources
find_program(PATCH_EXECUTABLE patch gpatch)
if(NOT PATCH_EXECUTABLE)
    message(SEND_ERROR "GNU Patch not found")
endif()

# Use Ninja when available.
find_program(NINJA_EXECUTABLE ninja)
if(NINJA_EXECUTABLE)
    set(LLVM_GENERATOR "Ninja")
else()
    set(LLVM_GENERATOR "Unix Makefiles")
endif()

# LLVM target
ExternalProject_Add(llvm
    #DEPENDS binutils
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    INSTALL_DIR ${MARVELL_ROOT}
    URL "${LLVM_URL}"
    URL_HASH "MD5=${LLVM_HASH}"
    PATCH_COMMAND ${PATCH_EXECUTABLE} --strip=1 --quiet
        --input=${LLVM_PATCH} --directory=<SOURCE_DIR>
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_JOB_POOL_COMPILE=${LLVM_PARALLEL_COMPILE_JOBS}
        -DCMAKE_JOB_POOL_LINK=${LLVM_PARALLEL_LINK_JOBS}
        -DLLVM_DEFAULT_TARGET_TRIPLE=armv7a-cros-linux-gnueabi
        -DLLVM_TARGETS_TO_BUILD=ARM
        -DLLVM_TARGET_ARCH=ARM
        -DLLVM_INCLUDE_DOCS=OFF
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_INCLUDE_UTILS=OFF
        -DLLVM_BUILD_UTILS=OFF
        -DLLVM_PARALLEL_COMPILE_JOBS=${LLVM_PARALLEL_COMPILE_JOBS}
        -DLLVM_PARALLEL_LINK_JOBS=${LLVM_PARALLEL_LINK_JOBS}
        -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON
        -DLLVM_ENABLE_BINDINGS=OFF
        -DBUILD_SHARED_LIBS=OFF
        ${CMAKE_ARGS}
    CMAKE_GENERATOR "${LLVM_GENERATOR}"
    LOG_DOWNLOAD ${ENABLE_LOG}
    LOG_CONFIGURE ${ENABLE_LOG}
    LOG_BUILD ${ENABLE_LOG}
    LOG_INSTALL ${ENABLE_LOG}
)

# Cleanup
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "src")
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "tmp")