#!/bin/bash
set -ex

cd $(dirname $0)/..
. scripts/build-common
. scripts/version

ln -sf bin/rancheros ./ros

for i in `./ros c images -i os-config.yml`; do
    [ "${FORCE_PULL}" != "1" ] && docker inspect $i >/dev/null 2>&1 || docker pull $i;
done

docker save rancher/os:${VERSION} `./ros c images -i os-config.yml` > ${BUILD}/images.tar
