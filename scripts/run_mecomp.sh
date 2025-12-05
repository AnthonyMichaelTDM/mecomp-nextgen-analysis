#!/bin/bash

# script to run mecomp with a temporary data directory and using the config file in the repo
MECOMP_DATA="../mecomp-tmp"
mkdir -p "$MECOMP_DATA"
MECOMP_CONFIG="../Mecomp.toml"

cp $MECOMP_CONFIG "$MECOMP_DATA/Mecomp.toml"

# override the library path to point to the local data directory
sed -i "s|library_paths = \[.*\]|library_paths = [\"${MECOMP_DATA}/../data/fma_small\"]|" "$MECOMP_DATA/Mecomp.toml"

MECOMP_DATA=$MECOMP_DATA mecomp-daemon --config "$MECOMP_DATA/Mecomp.toml" -l debug