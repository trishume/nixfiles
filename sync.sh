#!/bin/sh

rsync -av ./ nixbox:/etc/nixos/nixfiles --rsync-path="sudo rsync" --exclude=.git

