@echo off
if /I "%1"=="debug" (
    cmake -S . -B Debug -G "Visual Studio 18 2026" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=ExternalLibraries/vcpkg/scripts/buildsystems/vcpkg.cmake
    cmake --build Debug --config Debug
) else if /I "%1"=="release" (
    cmake -S . -B Release -G "Visual Studio 18 2026" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=ExternalLibraries/vcpkg/scripts/buildsystems/vcpkg.cmake
    cmake --build Release --config Release
) else (
    echo Usage: build.bat [debug^|release]
    exit /b 1
)
