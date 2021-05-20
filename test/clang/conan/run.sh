#!/bin/bash

set -ex

compiler=$1

docker rm -f ${compiler}
docker rm -f ubuntu

docker pull ${DOCKER_REPOSITORY}/${compiler}
docker run -t -d -v ${PWD}:/tmp/project --name ${compiler} ${DOCKER_REPOSITORY}/${compiler}
docker exec ${compiler} /tmp/project/test/clang/conan/test_conan.sh

docker stop ${compiler}
docker rm ${compiler}

# Mount Vanilla Ubuntu Xenial and run executables built with libstdc++.so.0.6.28
docker run -t -d -v ${PWD}:/tmp/project --name ubuntu ubuntu:xenial

docker exec -w /tmp/project ubuntu cp libunwind.so.1.0 /usr/lib/x86_64-linux-gnu/libunwind.so.1
docker exec -w /tmp/project ubuntu cp libstdc++.so.6.0.28 /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21

docker exec -w /tmp/project ubuntu ./foobar_cpp_libcpp
docker exec -w /tmp/project ubuntu ./foobar_c_libcpp

docker exec -w /tmp/project ubuntu ./foobar_cpp_libstdcpp
docker exec -w /tmp/project ubuntu ./foobar_c_libstdcpp

docker exec -w /tmp/project ubuntu ./foobar_cpp_libstdcpp11
docker exec -w /tmp/project ubuntu ./foobar_c_libstdcpp11

docker stop ubuntu
docker rm ubuntu
