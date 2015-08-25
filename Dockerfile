FROM alpine
RUN apk update && apk add coreutils util-linux bash parted syslinux e2fsprogs
COPY ./scripts/installer /scripts
COPY ./build.conf /scripts/

COPY ./dist/artifacts/vmlinuz ./dist/artifacts/initrd /dist/

ENTRYPOINT ["/scripts/lay-down-os"]
