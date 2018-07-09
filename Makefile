
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

default:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "  params                 Print build parameter"
	@echo "  build                  Build images"
#	@echo "  version                Print version of images"
	@echo "  test                   Test images"
	@echo "  publish                Publish images"
	@echo ""


params:
	@echo ""
	@echo " ICINGA2_VERSION: ${ICINGA2_VERSION}"
	@echo " BUILD_DATE     : $(BUILD_DATE)"
	@echo ""


build: base	master	satellite

alpine:	params	base-alpine	icinga2-alpine-master	icinga2-alpine-satellite
debian:	params	base-debian	icinga2-debian-master	icinga2-debian-satellite

base:	params	base-debian	base-alpine
master:	params	icinga2-alpine-master	icinga2-debian-master
satellite:	params	icinga2-alpine-satellite	icinga2-debian-satellite
from-source:	params	base-source	icinga2-source-master

# alpine based
base-alpine: params
	@echo ""
	@echo " build alpine based icinga2 base container"
	@echo ""
	cd icinga2-alpine ; \
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--tag $(NS)/$(REPO):alpine-$(ICINGA2_VERSION) . ; \
	cd ..

icinga2-alpine-master: params
	@echo ""
	@echo " build alpine based icinga2-master"
	@echo ""
	cd icinga2-master ; \
	docker build \
		--file Dockerfile.alpine \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--build-arg CERT_SERVICE_TYPE=${CERT_SERVICE_TYPE} \
		--build-arg CERT_SERVICE_VERSION=${CERT_SERVICE_VERSION} \
		--tag $(NS)/$(REPO):alpine-master-$(ICINGA2_VERSION) . ; \
	cd ..

icinga2-alpine-satellite: params
	@echo ""
	@echo " build icinga2-satellite"
	@echo ""
	cd icinga2-satellite ; \
	docker build \
		--file Dockerfile.alpine \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--tag $(NS)/$(REPO):alpine-satellite-$(ICINGA2_VERSION) . ; \
	cd ..

compose-alpine:	params
	echo "BUILD_DATE=$(BUILD_DATE)" > .env
	echo "BUILD_VERSION=$(BUILD_VERSION)" >> .env
	echo "ICINGA2_VERSION=$(ICINGA2_VERSION)" >> .env
	docker-compose \
		--file compose/head.yml \
		--file compose/database.yml \
		--file compose/icingaweb2.yml \
		--file compose/alpine/master.yml \
		config > docker-compose_alpine.yml
#		--file compose/alpine/satellite.yml \


# debian based
base-debian: params
	@echo ""
	@echo " build debian based icinga2 base container"
	@echo ""
	cd icinga2-debian ; \
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--tag $(NS)/$(REPO):debian-$(ICINGA2_VERSION) . ; \
	cd ..

icinga2-debian-master: params
	@echo ""
	@echo " build debian based icinga2-master"
	@echo ""
	cd icinga2-master ; \
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--build-arg CERT_SERVICE_TYPE=${CERT_SERVICE_TYPE} \
		--build-arg CERT_SERVICE_VERSION=${CERT_SERVICE_VERSION} \
		--tag $(NS)/$(REPO):debian-master-$(ICINGA2_VERSION) . ; \
	cd ..

icinga2-debian-satellite: params
	@echo ""
	@echo " build icinga2-satellite"
	@echo ""
	cd icinga2-satellite ; \
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--tag $(NS)/$(REPO):debian-satellite-$(ICINGA2_VERSION) . ; \
	cd ..

compose-debian:	params
	echo "BUILD_DATE=$(BUILD_DATE)" > .env
	echo "BUILD_VERSION=$(BUILD_VERSION)" >> .env
	echo "ICINGA2_VERSION=$(ICINGA2_VERSION)" >> .env
	docker-compose \
		--file compose/head.yml \
		--file compose/database.yml \
		--file compose/icingaweb2.yml \
		--file compose/debian/master.yml \
		--file compose/debian/satellite.yml \
		config > docker-compose_debian.yml


# alpine and self compiled
base-source: params
	@echo ""
	@echo " compile alpine based icinga2 base container"
	@echo ""
	cd build-from-source ; \
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--tag $(NS)/$(REPO):source-$(ICINGA2_VERSION) . ; \
	cd ..

icinga2-source-master: params
	@echo ""
	@echo " build alpine based icinga2-master"
	@echo ""
	cd icinga2-master ; \
	docker build \
		--file Dockerfile.source \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg ICINGA2_VERSION=${ICINGA2_VERSION} \
		--build-arg CERT_SERVICE_TYPE=${CERT_SERVICE_TYPE} \
		--build-arg CERT_SERVICE_VERSION=${CERT_SERVICE_VERSION} \
		--tag $(NS)/$(REPO):source-master-$(ICINGA2_VERSION) . ; \
	cd ..


compose-source:	params
	echo "BUILD_DATE=$(BUILD_DATE)" > .env
	echo "BUILD_VERSION=$(BUILD_VERSION)" >> .env
	echo "ICINGA2_VERSION=$(ICINGA2_VERSION)" >> .env
	docker-compose \
		--file compose/head.yml \
		--file compose/database.yml \
		--file compose/icingaweb2.yml \
		--file compose/source/master.yml \
		config > docker-compose_source.yml
#		--file compose/alpine/satellite.yml \




clean:
	docker rmi -f `docker images -q ${NS}/${REPO} | uniq`

shell:
	docker run \
		--rm \
		--name docker-icinga2-default \
		--interactive \
		--tty \
		$(NS)/$(REPO):$(ICINGA2_VERSION) \
		/bin/sh

#
# List all images
#
list:
	-docker images $(NS)/$(REPO)*

publish:
	docker push $(NS)/$(REPO):$(ICINGA2_VERSION)
	docker push $(NS)/$(REPO):$(ICINGA2_VERSION)-master
	docker push $(NS)/$(REPO):$(ICINGA2_VERSION)-satellite

compose: params
	docker-compose --file docker-compose_example.yml up --build
