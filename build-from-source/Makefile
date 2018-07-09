
.PHONY: ALL base-container icinga2-master icinga2-satellite clean

NS       := bodsch
REPO     := docker-icinga2

BUILD_DATE      := $(shell date +%Y-%m-%d)
BUILD_VERSION   := $(shell date +%y%m)

CERT_SERVICE_TYPE    ?= stable
CERT_SERVICE_VERSION ?= 0.18.0

ICINGA2_VERSION ?= 2.8.4

ICINGA2_VERSION ?= latest
export

default: params	base


params:
	@echo ""
	@echo " ICINGA2_VERSION: ${ICINGA2_VERSION}"
	@echo " BUILD_DATE     : $(BUILD_DATE)"
	@echo ""


build: base

base: params
	@echo ""
	@echo " build alpine based icinga2 base container"
	@echo ""
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--tag $(NS)/$(REPO) . ; \
	cd ..

clean:
	docker rmi -f `docker images -q ${NS}/${REPO} | uniq`

shell:
	docker run \
		--rm \
		--name docker-icinga2-default \
		--interactive \
		--tty \
		$(NS)/$(REPO) \
		/bin/sh

#
# List all images
#
list:
	-docker images $(NS)/$(REPO)*

