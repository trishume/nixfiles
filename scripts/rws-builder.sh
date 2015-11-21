#!/usr/bin/env bash

buildInputs="$sqlite"
source $stdenv/setup

PATH=$nim/bin:$PATH

echo "Copying RWS"
mkdir $out
cp -r $src/* $out/
echo "Linking stuff"
ln -s $jester $out/jester
ln -s $wikidata $out/data

echo "Building Server"
cd $out
nim c -d:release server.nim
patchelf --set-rpath $libPath ./server
