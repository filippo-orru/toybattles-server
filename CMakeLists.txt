cmake_minimum_required(VERSION 3.26)

set(CMAKE_C_COMPILER "gcc-13")
set(CMAKE_CXX_COMPILER "g++-13")

project(Microvolts-Emulator-V2 LANGUAGES C CXX ASM)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(APPLE)
    set(CMAKE_THREAD_LIBS_INIT "-lpthread")
    set(CMAKE_HAVE_THREADS_LIBRARY 1)
    set(CMAKE_USE_WIN32_THREADS_INIT 0)
    set(CMAKE_USE_PTHREADS_INIT 1)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
endif()

find_package(Threads REQUIRED)

# Prefer Ninja generator if available
set(CMAKE_GENERATOR "Ninja" CACHE STRING "Build system generator" FORCE)
if (WIN32)
    add_compile_definitions(_WIN32_WINNT=0x0601)
    if (MSVC)
        add_compile_options(/bigobj)
    endif()
endif()

set(Boost_NO_BOOST_CMAKE ON)
set(Boost_NO_BOOST_VERSION_CHECK ON)

if (WIN32)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")

elseif(APPLE)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Output)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Output)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Output)

elseif(UNIX)
    set(CMAKE_EXECUTABLE_SUFFIX ".elf")
    set(CMAKE_EXE_LINKER_FLAGS
        "${CMAKE_EXE_LINKER_FLAGS} -Wl,--allow-multiple-definition -Wl,-rpath=. -Wl,-rpath=/data/data/com.termux/files/usr/lib -Wl,--enable-new-dtags"
    )
    
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Output)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Output)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Output)
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

#find_package(Boost REQUIRED COMPONENTS system json beast asio)
find_package(Boost CONFIG REQUIRED COMPONENTS system json beast asio)
find_package(OpenSSL REQUIRED)
find_package(cryptopp CONFIG REQUIRED)
find_package(range-v3 CONFIG REQUIRED)
find_package(unofficial-mariadb-connector-cpp CONFIG REQUIRED)

include_directories(PUBLIC ${CMAKE_SOURCE_DIR}/ExternalLibraries)
add_subdirectory(Common)
add_subdirectory(AuthServer)
add_subdirectory(CastServer)
add_subdirectory(MainServer)
