#!/bin/bash
set -e

if [ "$(uname -s)" = "Darwin" ]; then
	MOUNT_POINT="/Volumes/RISCVToolchain"
	WORK_DIR="$MOUNT_POINT/workdir"

	hdiutil create -size 8g -fs "Case-sensitive APFS" -volname RISCVToolchain -type SPARSE ~/RISCVToolchain.sparseimage
	hdiutil attach ~/RISCVToolchain.sparseimage

	mkdir -p "$WORK_DIR"
	cd "$WORK_DIR"
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

# Set in-place editing flag for sed based on OS
if [ "$(uname -s)" = "Darwin" ]; then
  SED_INPLACE="-i ''"
else
  SED_INPLACE="-i"
fi

# set up the gnu toolchain
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain

$SED $SED_INPLACE -i '/shallow = true/d' .gitmodules
$SED $SED_INPLACE -i 's/--depth 1//g' Makefile.in

echo "building toolchain for host: $HOST, arch: $ARCH, abi: $ABI"
./configure --prefix=$PREFIX --with-cmodel=medany --disable-gdb --with-arch=$ARCH --with-abi=$ABI
make -j$(nproc 2>/dev/null || sysctl -n hw.logicalcpu)

cd ..

cd .dist

tar cvJf $HOST.tar.xz $HOST

cd ..
