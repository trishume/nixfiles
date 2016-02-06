#!/usr/bin/env bash

source $stdenv/setup

echo "Setting up output directory"
mkdir -p $out
cp -r ${src}/source ${out}/

echo "Building Vibe"
cd $out
find ${src}/source -name '*.d' -exec ${dmd}/bin/dmd -g -lib -ofvibed -version=VibeNoSSL -version=VibeLibeventDriver -version=VibeDefaultMain -L-L${libevent}/lib -L-levent -L-levent_pthreads -I${dmdpath} {} +
