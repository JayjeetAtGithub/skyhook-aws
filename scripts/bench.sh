#!/bin/bash
set -e

g++ bench.cc -larrow_skyhook_client -larrow_dataset -larrow -o bench
export LD_LIBRARY_PATH=/usr/local/lib
./bench $1
