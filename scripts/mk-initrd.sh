#!/bin/bash
set -ex

ARCH=${ARCH:-"amd64"}
DFS_IMAGE=${DFS_IMAGE:?"DFS_IMAGE not set"}

suffix=""
[ "$ARCH" == "amd64" ] || suffix="_${ARCH}"

cd $(dirname $0)/..
. scripts/build-common

INITRD_DIR=${BUILD}/initrd

rm -rf ${INITRD_DIR}/{usr,init}
mkdir -p ${INITRD_DIR}/usr/{bin,share/ros}

cp -rf ${BUILD}/kernel/lib ${INITRD_DIR}/usr/
cp ${BUILD}/images.tar     ${INITRD_DIR}/usr/share/ros/
cp os-config${suffix}.yml  ${INITRD_DIR}/usr/share/ros/os-config.yml
cp bin/ros                 ${INITRD_DIR}/usr/bin/
ln -s usr/bin/ros          ${INITRD_DIR}/init
ln -s bin                  ${INITRD_DIR}/usr/sbin
ln -s usr/sbin             ${INITRD_DIR}/sbin

DFS=$(docker create ${DFS_IMAGE})
trap "docker rm -fv ${DFS}" EXIT

docker export ${DFS} | tar xvf - -C ${INITRD_DIR}  --exclude=usr/bin/dockerlaunch \
                                                   --exclude=usr/share/git-core   \
                                                   --exclude=usr/bin/git          \
                                                   --exclude=usr/bin/ssh          \
                                                   --exclude=usr/libexec/git-core \
                                                   usr

if [ "$DEV_BUILD" == "1" ]; then
    COMPRESS="gzip -1"
else
    COMPRESS=lzma
fi

cd ${INITRD_DIR} && find | cpio -H newc -o | ${COMPRESS} > ${DIST}/artifacts/initrd
