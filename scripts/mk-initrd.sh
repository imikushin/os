#!/bin/bash
set -ex

ARCH=${ARCH:-"amd64"}
DFS_IMAGE=${DFS_IMAGE:?"DFS_IMAGE not set"}
FORCE_PULL=${FORCE_PULL:?"FORCE_PULL not set"}

suffix=""
[ "$ARCH" == "amd64" ] || suffix="_${ARCH}"

DFS_ARCH_IMAGE=${DFS_IMAGE}${suffix}

cd $(dirname $0)/..
. scripts/build-common

INITRD_DIR=${BUILD}/initrd

rm -rf ${INITRD_DIR}/{usr,init}
mkdir -p ${INITRD_DIR}/usr/{bin,share/ros}
mkdir -p ${INITRD_DIR}/var/lib/system-docker

images="$(./ros c images -i os-config${suffix}.yml)"
for i in ${images} ${DFS_IMAGE} ${DFS_ARCH_IMAGE}; do
    [ "${FORCE_PULL}" != "1" ] && docker inspect $i >/dev/null 2>&1 || docker pull $i;
done

cp -rf ${BUILD}/kernel/lib ${INITRD_DIR}/usr/
cp os-config${suffix}.yml  ${INITRD_DIR}/usr/share/ros/os-config.yml
cp bin/ros                 ${INITRD_DIR}/usr/bin/
ln -s usr/bin/ros          ${INITRD_DIR}/init
ln -s bin                  ${INITRD_DIR}/usr/sbin
ln -s usr/sbin             ${INITRD_DIR}/sbin

DFS_ARCH=$(docker create ${DFS_ARCH_IMAGE})
trap "docker rm -fv ${DFS_ARCH}" EXIT

docker export ${DFS_ARCH} | tar xvf - -C ${INITRD_DIR} --exclude=usr/bin/dockerlaunch \
                                                       --exclude=usr/share/git-core   \
                                                       --exclude=usr/bin/git          \
                                                       --exclude=usr/bin/ssh          \
                                                       --exclude=usr/libexec/git-core \
                                                       usr
DFS=$(docker run -d --privileged -v /lib/modules/$(uname -r):/lib/modules/$(uname -r) ${DFS_IMAGE})
trap "docker rm -fv ${DFS_ARCH} ${DFS}" EXIT
docker save ${images} | docker exec -i ${DFS} docker load
docker stop ${DFS}
docker run --rm --volumes-from=${DFS} debian:jessie tar -c -C /var/lib/docker ./image | tar -x -C ${INITRD_DIR}/var/lib/system-docker
docker run --rm --volumes-from=${DFS} debian:jessie tar -c -C /var/lib/docker ./overlay | tar -x -C ${INITRD_DIR}/var/lib/system-docker

if [ "$DEV_BUILD" == "1" ]; then
    COMPRESS="gzip -1"
else
    COMPRESS=lzma
fi

cd ${INITRD_DIR} && find | cpio -H newc -o | ${COMPRESS} > ${DIST}/artifacts/initrd
