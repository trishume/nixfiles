#!/usr/bin/env bash

source $stdenv/setup

PATH=$nim/bin:$PATH

echo "Copying RWS"
cp $src/* $out/
echo "Linking stuff"
ln -s $jester $out/jester
ln -s $wikidata $out/data

echo "Building Server"
cd $out
nim c -d:release server.nim
