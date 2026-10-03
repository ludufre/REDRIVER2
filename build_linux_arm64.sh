#!/bin/bash
# Builds a native Linux aarch64 binary (e.g. Raspberry Pi 5) inside a debian:bookworm linux/arm64 container,
# using the project's Raspberry Pi option (OpenGL ES 3 renderer). Output: src_rebuild/bin/Release/REDRIVER2
#
# Usage from the repo root (works on an Apple Silicon Mac or any arm64 Docker host):
#   docker run --rm --platform linux/arm64 -v "$PWD:/src" -w /src debian:bookworm bash /src/build_linux_arm64.sh
set -ex
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq build-essential git curl uuid-dev \
  libsdl2-dev libopenal-dev libjpeg-dev libgles-dev libegl-dev >/dev/null

# premake5 only ships x86_64 Linux binaries; build it for arm64
if ! command -v premake5; then
  git clone -q --depth 1 -b v5.0.0-beta2 https://github.com/premake/premake-core /tmp/premake-core
  make -C /tmp/premake-core -f Bootstrap.mak linux -j"$(nproc)" >/dev/null
  cp /tmp/premake-core/bin/release/premake5 /usr/local/bin/
fi

cd /src/src_rebuild
premake5 --raspberry-pi gmake2
cd build
make config=release_arm64 -j"$(nproc)"
