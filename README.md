# riscv32im and riscv64im Toolchain

The toolchain produced by this repository is meant for a RISC-V 32-bit/64-bit ISA with the core integer and multiplication extension.


## Prerequisites

Based on https://github.com/riscv-collab/riscv-gnu-toolchain.

### macOS

```bash
brew install python3 gawk gnu-sed make gmp mpfr libmpc isl zlib expat texinfo flock libslirp
```

### Linux

```bash
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev
```

## Build

```bash
./build.sh $HOST
```

`HOST` can be one of:
* riscv32im-linux-x86_64
* riscv32im-linux-arm64
* riscv32im-osx-arm64
* riscv32im-osx-x86_64
* riscv64im-linux-x86_64
* riscv64im-linux-arm64
* riscv64im-osx-arm64
* riscv64im-osx-x86_64

A final tarball lands in `.dist/$HOST`. For example:

```bash
$ ls .dist
riscv32im-osx-arm64
riscv32im-osx-arm64.tar.xz
```
