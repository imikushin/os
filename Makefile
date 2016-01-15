FORCE_PULL := 0
DEV_BUILD  := 0
ARCH       := amd64

include build.conf
include build.conf.$(ARCH)


installer: minimal
	docker build -t $(IMAGE_NAME):$(VERSION) .

bin/ros:
	mkdir -p $(dir $@)
	ARCH=$(ARCH) VERSION=$(VERSION) ./scripts/mk-ros.sh $@

./ros: bin/ros
ifeq "$(ARCH)" "amd64"
	ln -sf bin/ros ./ros
else
	ARCH=amd64 VERSION=$(VERSION) ./scripts/mk-ros.sh $@
endif

pwd := $(shell pwd)
include scripts/build-common


$(DIST)/artifacts/vmlinuz: $(BUILD)/kernel/
	mkdir -p $(dir $@)
	mv $(BUILD)/kernel/boot/vmlinuz* $@


$(BUILD)/kernel/:
	mkdir -p $@
	([ -e "$(COMPILED_KERNEL_URL)" ] && cat "$(COMPILED_KERNEL_URL)" || curl -L "$(COMPILED_KERNEL_URL)") | tar -xzf - -C $@


$(BUILD)/images.tar: ./ros
	ARCH=$(ARCH) FORCE_PULL=$(FORCE_PULL) ./scripts/mk-images-tar.sh


$(DIST)/artifacts/initrd: bin/ros $(BUILD)/kernel/ $(BUILD)/images.tar
	mkdir -p $(dir $@)
	DFS_IMAGE=$(DFS_IMAGE) DEV_BUILD=$(DEV_BUILD) ./scripts/mk-initrd.sh


$(DIST)/artifacts/rancheros.iso: minimal
	./scripts/mk-rancheros-iso.sh


$(DIST)/artifacts/iso-checksums.txt: $(DIST)/artifacts/rancheros.iso
	./scripts/mk-iso-checksums-txt.sh


version:
	@echo $(VERSION)

all: minimal installer iso

initrd: $(DIST)/artifacts/initrd

minimal: initrd $(DIST)/artifacts/vmlinuz

iso: $(DIST)/artifacts/rancheros.iso $(DIST)/artifacts/iso-checksums.txt

test: minimal
	cd tests/integration && tox

.PHONY: build-all minimal initrd iso installer version bin/ros integration-tests
