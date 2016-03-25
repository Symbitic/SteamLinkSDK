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

set(CMAKE_INSTALL_MESSAGE "NEVER")
set(MARVELL_ROOT "${CMAKE_CURRENT_BINARY_DIR}/install")

project(SteamLinkSDK LANGUAGES NONE VERSION 0.0.1)

option(ENABLE_TOOLCHAIN "Build the toolchain" ON)

set(ENABLE_LOG ON)

if("$ENV{TRAVIS}" STREQUAL "true")
    set(ENABLE_LOG OFF)

    set(TRAVIS_CFLAGS "-fbracket-depth=512")
    set(TRAVIS_CXXFLAGS "-fbracket-depth=512")

    if(APPLE)
        # Use Clang on OSX
        list(APPEND CMAKE_ARGS "-DCMAKE_C_COMPILER=/usr/bin/clang")
        list(APPEND CMAKE_ARGS "-DCMAKE_CXX_COMPILER=/usr/bin/clang++")
        list(APPEND AUTOCONF_ARGS "CC=/usr/bin/clang")
        list(APPEND AUTOCONF_ARGS "CXX=/usr/bin/clang++")
    elseif(UNIX)
        # Use GCC 5 on Linux
        list(APPEND CMAKE_ARGS "-DCMAKE_C_COMPILER=/usr/bin/clang-3.8")
        list(APPEND CMAKE_ARGS "-DCMAKE_CXX_COMPILER=/usr/bin/clang-3.8")
        list(APPEND AUTOCONF_ARGS "CC=/usr/bin/clang-3.8")
        list(APPEND AUTOCONF_ARGS "CXX=/usr/bin/clang-3.8")
    endif()
endif()

if(ENABLE_TOOLCHAIN)
    add_subdirectory(toolchain)
endif()

