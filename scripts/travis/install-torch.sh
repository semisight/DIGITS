#!/usr/bin/env bash
# Copyright (c) 2015, NVIDIA CORPORATION.  All rights reserved.

set -e

if [ "$#" -ne 1 ];
then
    echo "Usage: $0 INSTALL_DIR"
    exit 1
fi
INSTALL_DIR=$1

set -x

mkdir -p $INSTALL_DIR

# Install torch
curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash &>/dev/null
git clone https://github.com/torch/distro.git $INSTALL_DIR --recursive
cd $INSTALL_DIR
./install.sh -b

# Build LMDB
LMDB_DIR=$INSTALL_DIR/lmdb
pushd .
git clone https://gitorious.org/mdb/mdb.git $LMDB_DIR
cd $LMDB_DIR/libraries/liblmdb
make
popd

# Install luarocks modules
install_rock ()
{
    travis_wait $INSTALL_DIR/install/bin/luarocks install $@ &>/dev/null
}

install_rock image
install_rock inn
install_rock "https://raw.github.com/Sravan2j/lua-pb/master/lua-pb-scm-0.rockspec"
install_rock ccn2
install_rock lightningmdb \
    LMDB_INCDIR=$LMDB_DIR/libraries/liblmdb \
    LMDB_LIBDIR=$LMDB_DIR/libraries/liblmdb

