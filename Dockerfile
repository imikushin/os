FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y grub2 parted

COPY ./scripts/installer /scripts
COPY ./build.conf /scripts/

COPY ./dist/artifacts/vmlinux /dist/
COPY ./dist/artifacts/initrd  /dist/

ENTRYPOINT ["/scripts/lay-down-os"]
