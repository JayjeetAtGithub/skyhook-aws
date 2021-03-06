#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -eu

if [[ $# -lt 1 ]] ; then
    echo "./deploy_skyhook.sh [nodes] [branch] [deploy CLS libs] [build python] [build java] [nproc]"
    exit 1
fi

NODES=$1
BRANCH=${2:-arrow-master}
DEPLOY_CLS_LIBS=${3:-false}
BUILD_PYTHON_BINDINGS=${4:-false}
BUILD_JAVA_BINDINGS=${5:-false}
NPROC=${6:-4}

IFS=',' read -ra NODE_LIST <<< "$NODES"; unset IFS

sudo apt update 
sudo apt install -y python3 \
               python3-pip \
               python3-venv \
               pkg-config \
               python3-numpy \
               cmake \
               libradospp-dev \
               rados-objclass-dev \
               llvm \
               default-jdk \
               maven

if [ ! -d "/tmp/arrow" ]; then
  git clone https://github.com/uccross/arrow /tmp/arrow
  cd /tmp/arrow
  git submodule update --init --recursive
fi

cd /tmp/arrow
git fetch origin $BRANCH
git pull
git checkout $BRANCH
mkdir -p cpp/release
cd cpp/release

cmake -DARROW_SKYHOOK=ON \
  -DARROW_PARQUET=ON \
  -DARROW_WITH_SNAPPY=ON \
  -DARROW_WITH_ZLIB=ON \
  -DARROW_BUILD_EXAMPLES=ON \
  -DPARQUET_BUILD_EXAMPLES=ON \
  -DARROW_PYTHON=ON \
  -DARROW_ORC=ON \
  -DARROW_JAVA=ON \
  -DARROW_JNI=ON \
  -DARROW_DATASET=ON \
  -DARROW_CSV=ON \
  -DARROW_WITH_LZ4=ON \
  -DARROW_WITH_ZSTD=ON \
  ..

sudo make -j${NPROC} install

if [[ "${BUILD_PYTHON_BINDINGS}" == "true" ]]; then
  export WORKDIR=${WORKDIR:-$HOME}
  export ARROW_HOME=$WORKDIR/dist
  export PYARROW_WITH_DATASET=1
  export PYARROW_WITH_PARQUET=1
  export PYARROW_WITH_SKYHOOK=1

  sudo mkdir -p $HOME/dist/lib
  sudo mkdir -p $HOME/dist/include

  sudo cp -r /usr/local/lib/. $HOME/dist/lib
  sudo cp -r /usr/local/include/. $HOME/dist/include

  cd /tmp/arrow/python
  pip3 install -r requirements-build.txt -r requirements-test.txt
  pip3 install wheel
  rm -rf dist/*
  python3 setup.py build_ext --inplace --bundle-arrow-cpp bdist_wheel
  pip3 install --upgrade dist/*.whl
fi

if [[ "${DEPLOY_CLS_LIBS}" == "true" ]]; then
  cd /tmp/arrow/cpp/release/release
  for node in ${NODE_LIST[@]}; do
    scp libcls* $node:/tmp
    scp libarrow* $node:/tmp
    scp libparquet* $node:/tmp
    ssh $node sudo cp /tmp/libcls* /usr/lib/rados-classes
    ssh $node sudo cp /tmp/libarrow* /usr/lib
    ssh $node sudo cp /tmp/libparquet* /usr/lib
    ssh $node sudo systemctl restart ceph-osd.target
  done
fi

if [[ "${BUILD_JAVA_BINDINGS}" == "true" ]]; then
    mkdir -p /tmp/arrow/java/dist
    cp -r /tmp/arrow/cpp/release/release/libarrow_dataset_jni.so* /tmp/arrow/java/dist
    
    mvn="mvn -B -DskipTests -Dcheckstyle.skip -Drat.skip=true -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn"
    mvn="${mvn} -T 2C"

    cd /tmp/arrow/java
    ${mvn} clean install package -P arrow-jni -pl dataset,format,memory,vector -am -Darrow.cpp.build.dir=/tmp/arrow/cpp/release/release
fi

export LD_LIBRARY_PATH=/usr/local/lib
sudo cp /usr/local/lib/libparq* /usr/lib/
