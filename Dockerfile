FROM rancher/os-base:v0.4.0-dev
COPY ./scripts/installer /scripts
COPY ./scripts/version /scripts/
COPY /usr/lib/syslinux/mbr/mbr.bin /usr/share/syslinux/mbr.bin
COPY /boot/extlinux /usr/share/syslinux/boot/extlinux
