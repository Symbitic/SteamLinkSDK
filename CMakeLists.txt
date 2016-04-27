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

cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)
cmake_policy(SET CMP0048 NEW)

include(ExternalProject)

set(CMAKE_INSTALL_MESSAGE "NEVER")

project(SteamLinkSDK LANGUAGES NONE VERSION 0.0.1)

cmake_host_system_information(RESULT NUM_CORES QUERY NUMBER_OF_LOGICAL_CORES)

set(ENABLE_LOG ON)

if("$ENV{TRAVIS}" STREQUAL "true")
    set(ENABLE_LOG OFF)
endif()

# LLVM settings
set(LLVM_REPO "http://llvm.org/git/llvm.git")
set(LLVM_TAG "release_38")

# Clang settings
set(CLANG_REPO "http://llvm.org/git/clang.git")
set(CLANG_TAG "release_38")

# LLD settings
set(LLD_REPO "http://llvm.org/git/lld.git")
set(LLD_TAG "release_38")

# Compiler-rt settings
set(COMPILER_RT_REPO "http://llvm.org/git/compiler-rt.git")
set(COMPILER_RT_TAG "release_38")

# libcxx settings
set(LIBCXX_REPO "http://llvm.org/git/libcxx.git")
set(LIBCXX_TAG "release_38")

# Use Ninja when available.
#find_program(NINJA_EXECUTABLE ninja)
if(NINJA_EXECUTABLE)
    set(LLVM_GENERATOR "Ninja")
else()
    set(LLVM_GENERATOR "Unix Makefiles")
endif()

# Create LLVM external-project.
ExternalProject_Add(LLVM
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/install"
    GIT_REPOSITORY "${LLVM_REPO}"
    GIT_TAG "${LLVM_TAG}"
    CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE:STRING=Release
        -DCMAKE_JOB_POOL_COMPILE:STRING=${NUM_CORES}
        -DCMAKE_JOB_POOL_LINK:STRING=${NUM_CORES}
        -DLLVM_DEFAULT_TARGET_TRIPLE:STRING=armv7a-cros-linux-gnueabi
        -DLLVM_TARGETS_TO_BUILD:STRING=ARM
        -DLLVM_TARGET_ARCH:STRING=ARM
        -DLLVM_INCLUDE_DOCS:BOOL=OFF
        -DLLVM_INCLUDE_EXAMPLES:BOOL=OFF
        -DLLVM_INCLUDE_TESTS:BOOL=OFF
        -DLLVM_INCLUDE_UTILS:BOOL=OFF
        -DLLVM_BUILD_UTILS:BOOL=OFF
        -DLLVM_INSTALL_TOOLCHAIN_ONLY:BOOL=ON
        -DLLVM_ENABLE_SPHINX:BOOL=OFF
        -DLLVM_ENABLE_BINDINGS:BOOL=OFF
        -DCLANG_PLUGIN_SUPPORT:BOOL=ON
        -DCLANG_BUILD_EXAMPLES:BOOL=OFF
        -DCLANG_ENABLE_STATIC_ANALYZER:BOOL=OFF
        -DCLANG_ENABLE_ARCMT:BOOL=OFF
        -DLLD_USE_VTUNE:BOOL=OFF
        -DGCC_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS:BOOL=OFF
    CMAKE_GENERATOR "${LLVM_GENERATOR}"
    LOG_DOWNLOAD ${ENABLE_LOG}
    LOG_CONFIGURE ${ENABLE_LOG}
    LOG_BUILD ${ENABLE_LOG}
    LOG_INSTALL ${ENABLE_LOG}
)

# Add Clang to LLVM.
ExternalProject_Add_Step(LLVM clang
    COMMAND ${GIT_EXECUTABLE} clone -b ${CLANG_TAG} ${CLANG_REPO}
        <SOURCE_DIR>/tools/clang
    DEPENDEES patch
    LOG ${ENABLE_LOG}
    COMMENT "Performing clang step for 'LLVM'"
)

# Post-install
ExternalProject_Add_Step(LLVM post-install
    COMMAND ${CMAKE_COMMAND} -E remove -f
        <INSTALL_DIR>/bin/clang-cl
        <INSTALL_DIR>/bin/clang-format
        <INSTALL_DIR>/bin/git-clang-format
    DEPENDEES install
    LOG ${ENABLE_LOG}
    COMMENT "Performing post-install step for 'LLVM'"
)

# Install SteamLinkSDK
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/install/
    DESTINATION SteamLinkSDK
    USE_SOURCE_PERMISSIONS
    PATTERN ".*" EXCLUDE
)

# Cleanup
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "install")
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "src")
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "tmp")