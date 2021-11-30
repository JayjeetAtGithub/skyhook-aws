#!/bin/bash
set -ex

# $1: No. of OSDs
# $2: Size of objects

do_ssh() {
    ssh -i 'jayjeet2.pem' ubuntu@54.146.137.28 $1
}

BASE_DIR=results/radosbench/${1}/${2}
mkdir -p ${BASE_DIR}
do_ssh "rados bench --no-hints -b ${2} -t 32 -p cephfs_data 60 write --no-cleanup --format=json-pretty" > ${BASE_DIR}/write.json
do_ssh "rados bench --no-hints -t 32 -p cephfs_data 60 seq --no-cleanup --format=json-pretty" > ${BASE_DIR}/seq.json
do_ssh "rados bench --no-hints -t 32 -p cephfs_data 60 rand --no-cleanup --format=json-pretty" > ${BASE_DIR}/rand.json
