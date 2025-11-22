FROM ubuntu:25.10 AS base

RUN apt-get update
WORKDIR /app

FROM base AS builder

RUN apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    python3 \
    python3-pip \
    pkg-config \
    libssl-dev \
    software-properties-common \
    curl \
    zip \
    unzip \
    tar \
    gcc-13 \
    g++-13

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 50 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 50

COPY ./ExternalLibraries/vcpkg /app/ExternalLibraries/vcpkg
COPY ./vcpkg.json /app/vcpkg.json

RUN ./ExternalLibraries/vcpkg/bootstrap-vcpkg.sh
ENV VCPKG_BINARY_SOURCES=files,/cache/vcpkg
RUN --mount=type=cache,target=/cache/vcpkg ./ExternalLibraries/vcpkg/vcpkg install

COPY . /app

RUN cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=ExternalLibraries/vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --config Release

FROM base AS runtime

RUN apt-get install -y \
    libssl3 \
    libmariadb3

WORKDIR /app

COPY --from=builder /app/AuthServer.elf .
COPY --from=builder /app/MainServer.elf .
COPY --from=builder /app/CastServer.elf .

COPY ./docker/docker-entrypoint.sh .
RUN chmod +x ./docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
