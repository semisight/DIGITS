#/usr/bin/env bash
# Copyright (c) 2015, NVIDIA CORPORATION.  All rights reserved.

set -e

if [ "$#" -ne 1 ];
then
    echo "Usage: $0 INSTALL_DIR"
    exit 1
fi
INSTALL_DIR=$1
mkdir -p $INSTALL_DIR

TORCH_URL="https://github.com/torch/torch7.git"

# Get source
git clone --depth 1 $TORCH_URL $INSTALL_DIR
cd $INSTALL_DIR

# Install dependencies
sudo apt-get -qq update
sudo apt-get -qq install gfortran gcc-multilib gfortran-multilib liblapack-dev
curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | sudo bash 2>&1 >/dev/null

# clone distro (sources to be used)
git clone https://github.com/torch/distro.git distro --recursive
cd distro && git submodule update --init --recursive

# Build source
mkdir build && cd build
CMAKE_LIBRARY_PATH=/opt/OpenBLAS/include:/opt/OpenBLAS/lib:$CMAKE_LIBRARY_PATH
cmake .. -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DCMAKE_BUILD_TYPE=Release -DWITH_LUAJIT21=ON
make && make install

# luarocks install
cd $INSTALL_DIR
luarocks make rocks/torch-scm-1.rockspec

# test torch
luajit -ltorch -e "t=torch.test(); if t.errors[1] then os.exit(1) end"

# DIGITS lua dependencies
luarocks install image
luarocks install inn
luarocks install "https://raw.github.com/Sravan2j/lua-pb/master/lua-pb-scm-0.rockspec"
luarocks install ccn2
luarocks install lightningmdb
