SHELL=bash
.SHELLFLAGS=-euo pipefail -c

VERSION=22.12

help:
	@echo type make build-hyperv

build-hyperv: truenas-scale-${VERSION}-amd64-hyperv.box

truenas-scale-${VERSION}-amd64-hyperv.box: truenas-scale.pkr.hcl Vagrantfile.template
	del $@
	set PACKER_KEY_INTERVAL=10ms && set CHECKPOINT_DISABLE=1 && set PACKER_LOG=1 && set PACKER_LOG_PATH=$@.log && set PKR_VAR_vagrant_box=$@ && set DUMMY=DUMMY \
		&& packer build -only=hyperv-iso.truenas-scale-amd64 -on-error=abort -timestamp-ui truenas-scale.pkr.hcl


.PHONY: help build-hyperv