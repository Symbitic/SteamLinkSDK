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

# Identify the number of cores we can use.
ProcessorCount(N)
if(NOT N EQUAL 0)
    set(JOB_FLAGS -j${N})
endif()

# Binutils settings
set(BINUTILS_URL "ftp://ftp.gnu.org/gnu/binutils/binutils-2.26.tar.bz2")
set(BINUTILS_HASH "64146a0faa3b411ba774f47d41de239f")
set(BINUTILS_PATCH "${CMAKE_CURRENT_SOURCE_DIR}/patches/binutils-2.26.patch")

# LLVM settings
set(LLVM_URL "http://llvm.org/releases/3.7.1/llvm-3.7.1.src.tar.xz")
set(LLVM_HASH "bf8b3a2c79e61212c5409041dfdbd319")
set(LLVM_PATCH "${CMAKE_CURRENT_SOURCE_DIR}/patches/llvm-3.7.1.patch")

# Clang settings
set(CLANG_URL "http://llvm.org/releases/3.7.1/cfe-3.7.1.src.tar.xz")
set(CLANG_HASH "0acd026b5529164197563d135a8fd83e")
set(CLANG_PATCH "${CMAKE_CURRENT_SOURCE_DIR}/patches/clang-3.7.1.patch")

# Require GNU Make for building Autotools projects
find_program(MAKE_EXECUTABLE make gmake)
if(NOT MAKE_EXECUTABLE)
    message(SEND_ERROR "GNU Make not found")
endif()

# Require GNU Patch for patching downloaded sources
find_program(PATCH_EXECUTABLE patch gpatch)
if(NOT PATCH_EXECUTABLE)
    message(SEND_ERROR "GNU Patch not found")
endif()

# Use Ninja when available.
find_program(NINJA_EXECUTABLE ninja)
if(NINJA_EXECUTABLE)
    set(LLVM_GENERATOR "Ninja")
    set(CLANG_GENERATOR "Ninja")
else()
    set(LLVM_GENERATOR "Unix Makefiles")
    set(CLANG_GENERATOR "Unix Makefiles")
endif()

# Binutils target
ExternalProject_Add(binutils
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    INSTALL_DIR ${MARVELL_ROOT}
    URL "${BINUTILS_URL}"
    URL_HASH "MD5=${BINUTILS_HASH}"
    PATCH_COMMAND ${PATCH_EXECUTABLE} --strip=1 --quiet
        --input=${BINUTILS_PATCH} --directory=<SOURCE_DIR>
    CONFIGURE_COMMAND <SOURCE_DIR>/configure
        --prefix=<INSTALL_DIR>
        --target=armv7a-cros-linux-gnueabi
        --disable-nls
        --disable-shared
        --disable-debug
        --disable-dependency-tracking
        --disable-werror
        --disable-bootstrap
        --disable-multilib
        --enable-checking=release
        --enable-lto
        --enable-plugins
        --enable-gold=yes
        --enable-ld=default
        --enable-poison-system-directories
        --enable-install-libbfd
        --enable-build-with-cxx
        --enable-nlsi=no
        "CFLAGS=-w -O2 ${TRAVIS_CFLAGS}"
        "CXXFLAGS=-w -O2 ${TRAVIS_CXXFLAGS}"
        ${AUTOCONF_ARGS}
    BUILD_COMMAND ${MAKE_EXECUTABLE} ${JOB_FLAGS}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    LOG_DOWNLOAD ${ENABLE_LOG}
    LOG_CONFIGURE ${ENABLE_LOG}
    LOG_BUILD ${ENABLE_LOG}
    LOG_INSTALL ${ENABLE_LOG}
)

# LLVM target
ExternalProject_Add(llvm
    DEPENDS binutils
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

ExternalProject_Get_Property(llvm binary_dir)
set(LLVM_CONFIG_EXECUTABLE ${binary_dir}/bin/llvm-config)

# Clang target
ExternalProject_Add(clang
    DEPENDS llvm
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    INSTALL_DIR ${MARVELL_ROOT}
    URL "${CLANG_URL}"
    URL_HASH "MD5=${CLANG_HASH}"
    PATCH_COMMAND ${PATCH_EXECUTABLE} --strip=1 --quiet
        --input=${CLANG_PATCH} --directory=<SOURCE_DIR>
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_PREFIX_PATH=<INSTALL_DIR>
        -DCMAKE_PROGRAM_PATH=<INSTALL_DIR>/bin
        -DCLANG_PLUGIN_SUPPORT=ON
        -DCLANG_BUILD_EXAMPLES=OFF
        -DCLANG_ENABLE_STATIC_ANALYZER=OFF
        -DCLANG_ENABLE_ARCMT=OFF
        -DCLANG_ENABLE_DIAGTOOL=OFF
        -DCLANG_ENABLE_CLANGFORMAT=OFF
        -DCLANG_ENABLE_CLANGFUZZER=OFF
        -DCLANG_ENABLE_CINDEXTEST=OFF
        -DLLVM_CONFIG=${LLVM_CONFIG_EXECUTABLE}
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_INCLUDE_DOCS=OFF
        -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON
        -DGCC_INSTALL_PREFIX=<INSTALL_DIR>
        ${CMAKE_ARGS}
    CMAKE_GENERATOR "${CLANG_GENERATOR}"
    LOG_DOWNLOAD ${ENABLE_LOG}
    LOG_CONFIGURE ${ENABLE_LOG}
    LOG_BUILD ${ENABLE_LOG}
    LOG_INSTALL ${ENABLE_LOG}
)

# Cleanup
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "src")
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "tmp")