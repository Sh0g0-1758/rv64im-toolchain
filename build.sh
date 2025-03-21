#!/bin/bash
set -e

if [ "$(uname -s)" = "Darwin" ]; then

MOUNT_POINT="/Volumes/RISCVToolchain"
WORK_DIR="$MOUNT_POINT/workdir"

# Check if the disk image already exists
if [ -f ~/RISCVToolchain.sparseimage ]; then
    echo "Disk image already exists."
else
    echo "Creating disk image..."
    # Create a sparse image with a case-sensitive APFS file system
    hdiutil create -size 8g -fs "Case-sensitive APFS" -volname RISCVToolchain -type SPARSE ~/RISCVToolchain.sparseimage || { echo "Error creating disk image"; exit 1; }
fi

echo "Mounting disk image..."
hdiutil attach ~/RISCVToolchain.sparseimage || { echo "Error mounting disk image"; exit 1; }

echo "Creating working directory..."
mkdir -p "$WORK_DIR" || { echo "Error creating working directory"; exit 1; }

echo "Changing to working directory..."
cd "$WORK_DIR" || { echo "Error changing to working directory"; exit 1; }

echo "Setup complete. Working directory is $WORK_DIR"
else
    WORK_DIR="$(pwd)/workdir"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
fi

HOST=$1
PREFIX=$WORK_DIR/.dist/$HOST

# Extract bit size from host name
if [[ $HOST =~ riscv32im ]]; then
  ARCH="rv32im"
  ABI="ilp32"
elif [[ $HOST =~ riscv64im ]]; then
  ARCH="rv64im"
  ABI="lp64"
else
  echo "Unknown host: $HOST"
  exit 1
fi

if command -v gsed &>/dev/null; then
  SED=gsed
else
  SED=sed
fi

# set up the gnu toolchain
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain
$SED -i '/shallow = true/d' .gitmodules
$SED -i 's/--depth 1//g' Makefile.in

echo "building toolchain for host: $HOST, arch: $ARCH, abi: $ABI"
./configure --prefix=$PREFIX --with-cmodel=medany --disable-gdb --with-arch=$ARCH --with-abi=$ABI
make -j$(nproc 2>/dev/null || sysctl -n hw.logicalcpu)

cd ..

cd .dist

tar cvJf $HOST.tar.xz $HOST

cd ..
