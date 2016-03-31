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
ProcessorCount(CLANG_PARALLEL_COMPILE_JOBS)
ProcessorCount(CLANG_PARALLEL_LINK_JOBS)

# Clang settings
set(CLANG_URL "http://llvm.org/releases/3.8.0/cfe-3.8.0.src.tar.xz")
set(CLANG_HASH "cc99e7019bb74e6459e80863606250c5")
set(CLANG_PATCH "${PATCH_DIR}/clang-3.8.0.patch")

# Require GNU Patch for patching downloaded sources
find_program(PATCH_EXECUTABLE patch gpatch)
if(NOT PATCH_EXECUTABLE)
    message(SEND_ERROR "GNU Patch not found")
endif()

# Use Ninja when available.
find_program(NINJA_EXECUTABLE ninja)
if(NINJA_EXECUTABLE)
    set(CLANG_GENERATOR "Ninja")
else()
    set(CLANG_GENERATOR "Unix Makefiles")
endif()

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