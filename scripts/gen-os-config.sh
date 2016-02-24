#!/bin/bash
set -ex

cd $(dirname $0)/..

set -a
. build.defaults
[ -f .build.defaults ] && . .build.defaults

SUFFIX=""
[ "${ARCH}" == "amd64" ] || SUFFIX="_${ARCH}"

build/host_ros c generate < os-config.tpl.yml > $1
