#!/bin/bash
set -e

# -- Build script for MacOS --

# Export flags so vcpkg dependencies (like cryptopp) use them
export CFLAGS="-fpermissive"
export CXXFLAGS="-fpermissive"

export CC=$(which gcc-13)
export CXX=$(which g++-13)

if [ -z "$CC" ] || [ -z "$CXX" ]; then
    echo "Error: gcc-13 / g++-13 not found. Please install them with 'brew install gcc@13'."
    exit 1
fi

# Clean build directory to remove old CMake cache if --clean is passed
if [ "$2" == "--clean" ]; then
    if [ -d "$BUILD_DIR" ]; then
        echo "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
    fi
    if [ -d "vcpkg_installed" ]; then
        echo "Cleaning vcpkg_installed directory..."
        rm -rf "vcpkg_installed"
    fi
fi

# Set up vcpkg
## Clone vcpkg if not already present
if [ ! -d "ExternalLibraries/vcpkg" ]; then
    git clone https://github.com/microsoft/vcpkg.git ExternalLibraries/vcpkg
fi
## Bootstrap vcpkg
if [ ! -f "ExternalLibraries/vcpkg/vcpkg" ]; then
    ./ExternalLibraries/vcpkg/bootstrap-vcpkg.sh
fi
## Install dependencies
./ExternalLibraries/vcpkg/vcpkg install

# Build the project with CMake and Ninja
BUILD_DIR="build"
BUILD_TYPE="${1:-Release}"

# Build type must be either Release or Debug
if [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "Debug" ]; then
    echo "Error: Invalid build type '$BUILD_TYPE'. Use 'Release' or 'Debug'."
    exit 1
fi

echo "Building ($BUILD_TYPE)..."

cmake -B "$BUILD_DIR" -S . \
    -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE=ExternalLibraries/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

cmake --build "$BUILD_DIR" --config "$BUILD_TYPE"

echo "Build complete! Took $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds."
