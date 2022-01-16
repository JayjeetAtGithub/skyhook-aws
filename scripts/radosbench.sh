#!/bin/bash
set -ex

# $1: No. of OSDs
# $2: Experiment name
# $3: Client
# $4: Number of threads
# $5: Number of seconds

do_ssh() {
    ssh -i 'jayjeet2-frankfurt.pem' ubuntu@$1 $2
}

blocksizes=( 8M )

for blksize in "${blocksizes[@]}"
do

BASE_DIR=results/${2}/${1}/${blksize}
mkdir -p ${BASE_DIR}
do_ssh ${3} "rados bench --no-hints -b ${blksize} -t ${4} -p cephfs_data ${5} write --no-cleanup --format=json-pretty" > ${BASE_DIR}/write.json
ed ${BASE_DIR}/write.json <<< $'1d\nw\nq'

do_ssh ${3} "rados bench --no-hints -t ${4} -p cephfs_data ${5} seq --no-cleanup --format=json-pretty" > ${BASE_DIR}/seq.json
ed ${BASE_DIR}/seq.json <<< $'1d\nw\nq'

do_ssh ${3} "rados bench --no-hints -t ${4} -p cephfs_data ${5} rand --no-cleanup --format=json-pretty" > ${BASE_DIR}/rand.json
ed ${BASE_DIR}/rand.json <<< $'1d\nw\nq'

done
