#!/usr/bin/env bash

source $stdenv/setup

echo "Setting up output directory"
mkdir -p $out
cp -r $src/* $out/
ln -s $wikidata $out/data

echo "Building Server"
cd $out
${dmd}/bin/dmd -g -ofratewithscience -version=VibeNoSSL -version=VibeLibeventDriver -version=VibeDefaultMain -L-L${sqlite}/lib -L-L${libevent}/lib -L-lsqlite3 -L-levent -L-levent_pthreads -I${dmdpath} ${src}/source/*.d ${d2sqlite3}/source/*.d ${gfm}/core/gfm/core/queue.d ${vibed}/vibed.a
#dub build --cache=local --vverbose --build=release
#patchelf --set-rpath $libPath ./ratewithscience
