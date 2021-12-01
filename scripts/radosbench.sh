#!/bin/bash
set -ex

# $1: No. of OSDs
# $2: Size of objects
# $3: Experiment name
# $4: Client
# $5: Number of threads

do_ssh() {
    ssh -i 'jayjeet2-frankfurt.pem' ubuntu@$1 $2
}

BASE_DIR=results/${3}/${1}/${2}
mkdir -p ${BASE_DIR}
do_ssh ${4} "rados bench --no-hints -b ${2} -t ${5} -p cephfs_data 60 write --no-cleanup --format=json-pretty" > ${BASE_DIR}/write.json
ed ${BASE_DIR}/write.json <<< $'1d\nw\nq'

do_ssh ${4} "rados bench --no-hints -t ${5} -p cephfs_data 60 seq --no-cleanup --format=json-pretty" > ${BASE_DIR}/seq.json
ed ${BASE_DIR}/seq.json <<< $'1d\nw\nq'

do_ssh ${4} "rados bench --no-hints -t ${5} -p cephfs_data 60 rand --no-cleanup --format=json-pretty" > ${BASE_DIR}/rand.json
ed ${BASE_DIR}/rand.json <<< $'1d\nw\nq'
