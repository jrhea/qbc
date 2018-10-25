SHELL := /bin/bash
BUILDDIR = build
BUILDS = linux-64 darwin-64
HOST_OS = $(shell uname -s | tr '[:upper:]' '[:lower:]')
GOOS = $(HOST_OS)
GOARCH = 64
BINTRAY_USER = jdoe
BINTRAY_KEY = pass

QBC_NAME = qbc
VERSION = 0.3

QUORUM_NAME = quorum
QUORUM_VERSION = v2.1.1-grpc
QUORUM_REPO = https://github.com/ConsenSys/quorum.git
QUORUM_BUILD = make all
QUORUM_BINPATH = build/bin
QUORUM_OUTFILES = geth bootnode

CONSTELLATION_NAME = constellation
CONSTELLATION_VERSION = v0.3.2
CONSTELLATION_REPO = https://github.com/jpmorganchase/constellation.git
CONSTELLATION_BUILD = stack --allow-different-user install && cp $(HOME)/.local/bin/constellation-node ./bin/
CONSTELLATION_BINPATH = bin
CONSTELLATION_OUTFILES = constellation-node

CRUX_NAME = crux
CRUX_VERSION = v1.0.3
CRUX_REPO = https://github.com/blk-io/crux.git
CRUX_BUILD = make setup && make
CRUX_BINPATH = bin
CRUX_OUTFILES = crux

PROJECTS = $(shell echo $(QUORUM_NAME) $(CONSTELLATION_NAME) $(CRUX_NAME) | tr '[:lower:]' '[:upper:]')
PACKAGES = $(foreach project,$(PROJECTS), $(foreach build,$(BUILDS), $($(project)_NAME)-$($(project)_VERSION)-$(build) ) )
RUN_CONTAINERS = $(firstword $(BUILDS))-docker-$(QUORUM_NAME) $(firstword $(BUILDS))-docker-$(CONSTELLATION_NAME) $(firstword $(BUILDS))-docker-$(CRUX_NAME)
BUILD_CONTAINERS = docker-build-$(VERSION)

.PHONY: all qbc qbc-containers qbc-tarballs clean clobber check_clobber release tag test circleci-macos
.DEFAULT_GOAL := qbc

ifneq ($(filter all,$(MAKECMDGOALS)),)
.NOTPARALLEL:
endif

all: clean
	$(MAKE) qbc && $(MAKE) test

qbc: qbc-tarballs qbc-containers

qbc-containers: $(RUN_CONTAINERS)

qbc-tarballs: $(foreach build,$(BUILDS),tarball-$(build))

tarball-%: $(PACKAGES)
	cd $(BUILDDIR) && tar czf qbc-$(VERSION)-$*.tar.gz $(addsuffix .tar.gz, $?)

$(PACKAGES): $(addprefix .build~,$(PACKAGES))
	$(eval PROJECT = $(shell echo $(firstword $(subst -, ,$@))| tr '[:lower:]' '[:upper:]'))
	@test -e $(BUILDDIR)/$@.tar.gz \
	|| echo "BUILD, TAR & GZIP PACKAGE: $@" && cd $(BUILDDIR) \
	&& tar cf $@.tar -C $(CURDIR)/docs/$($(PROJECT)_NAME) . \
	&& tar rf $@.tar -C $@/$($(PROJECT)_BINPATH) $($(PROJECT)_OUTFILES) \
	&& find $@/$($(PROJECT)_BINPATH) -name '*.so.*' | xargs tar rf $@.tar \
	&& gzip -f $@.tar

.build~%: $(addprefix .clone~,$(PACKAGES)) | $(BUILD_CONTAINERS)
	$(eval PACKAGE = $*)
	$(eval PROJECT = $(shell echo $(firstword $(subst -, ,$(PACKAGE)))| tr '[:lower:]' '[:upper:]'))
	$(eval CONTAINER_$(PROJECT)_BUILD = docker run -i -v $(shell pwd)/$(BUILDDIR)/$(PACKAGE):/tmp/$($(PROJECT)_NAME) consensys/linux-build:$(VERSION) ./build-$($(PROJECT)_NAME).sh)
	@test -e $(BUILDDIR)/$@ \
	|| ( [[ "$(PACKAGE)" == *"linux"* ]] && ( cd $(BUILDDIR)/$(PACKAGE) && $(CONTAINER_$(PROJECT)_BUILD) && touch ../$@ ) || echo "SKIP" \
	&&   [[ "$(PACKAGE)" == *"darwin"* ]] && ( cd $(BUILDDIR)/$(PACKAGE) && $($(PROJECT)_BUILD) && touch ../$@) || echo "SKIP" )

.clone~%:
	$(eval PACKAGE = $*)
	$(eval PROJECT = $(shell echo $(firstword $(subst -, ,$(PACKAGE)))| tr '[:lower:]' '[:upper:]'))
	@mkdir -p $(BUILDDIR)
	@test -e $(BUILDDIR)/$(PACKAGE) || ( echo "CLONE: $($(PROJECT)_NAME) INTO: $(PACKAGE)" \
	&& cd $(BUILDDIR) \
	&& git clone --branch $($(PROJECT)_VERSION) --depth 1 $($(PROJECT)_REPO) $(PACKAGE) \
	&& touch $@ )

$(BUILD_CONTAINERS):
	@test -e $(CURDIR)/$(BUILDDIR)/.$@ || ( echo "BUILDING BUILD_CONTAINER: $@" \
	&& mkdir -p $(CURDIR)/$(BUILDDIR)/$@ \
	&& cd $(CURDIR)/$(BUILDDIR)/$@ \
	&& cp $(CURDIR)/docker/linux-build.Dockerfile linux-build.Dockerfile \
	&& docker build --build-arg CACHEBUST=$(date +%s) -f linux-build.Dockerfile -t consensys/linux-build:$(VERSION) . \
	&& touch $(CURDIR)/$(BUILDDIR)/.$@ )

$(RUN_CONTAINERS): $(PACKAGES)
	$(eval PROJECT = $(shell echo $(lastword $(subst -, ,$@))| tr '[:lower:]' '[:upper:]'))
	$(eval OS = $(shell echo $(word 1, $(subst -, ,$@))))
	$(eval ARCH = $(shell echo $(word 2, $(subst -, ,$@))))
	@test -e $(CURDIR)/$(BUILDDIR)/.docker-$($(PROJECT)_NAME) || ( echo "BUILDING RUN_CONTAINER: $@" \
	&& mkdir -p $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& cp $(CURDIR)/docker/$($(PROJECT)_NAME)-start.sh $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& mv $(CURDIR)/build/$($(PROJECT)_NAME)-$($(PROJECT)_VERSION)-$(OS)-$(ARCH).tar.gz $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& cd $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& cp ../../docker/$($(PROJECT)_NAME).Dockerfile $($(PROJECT)_NAME).Dockerfile \
	&& docker build --build-arg osarch=$(OS)-$(ARCH) --build-arg version=$($(PROJECT)_VERSION) -f $($(PROJECT)_NAME).Dockerfile -t consensys/$($(PROJECT)_NAME):$(VERSION) . \
	&& docker tag consensys/$($(PROJECT)_NAME):$(VERSION) consensys/$($(PROJECT)_NAME):latest \
	&& touch $(CURDIR)/$(BUILDDIR)/.docker-$($(PROJECT)_NAME) )

test: $(RUN_CONTAINERS)
	@echo "Make sure all containers are stopped"
	@cd tests/constellation_quorum && ( make stop && cd ../.. || cd ../.. )
	@cd tests/crux_quorum && ( make stop && cd ../.. || cd ../.. )
	@cd tests/crux_relays_quorum && ( make stop && cd ../.. || cd ../.. )
	@echo "Run Tests"
	@cd tests/constellation_quorum && make clean && ( make test && make stop || make stop )
	@cd tests/crux_quorum && make stop && make clean && ( make test && make stop || make stop )
	@cd tests/crux_relays_quorum && make stop && make clean && ( make test && make stop || make stop )

release: tag $(BUILDDIR)/.dockerpush $(BUILDDIR)/.tgzpush
	git push origin master --tags

tag:
	git tag -s $(VERSION)

$(BUILDDIR)/.dockerpush: dockerlogin $(addprefix $(BUILDDIR)/,$(addsuffix .$@-$(VERSION)-, $(shell echo $(PROJECTS) | tr '[:upper:]' '[:lower:]')))
	touch $(BUILDDIR)/.dockerpush

$(BUILDDIR)/.dockerlogin: 
	docker login -u $(BINTRAY_USER) -p $(BINTRAY_KEY) consensys-docker-qbc.bintray.io
	
$(BUILDDIR)/.dockerpush-$(VERSION)-%: containers
	docker tag consensys/:$(VERSION) consensys-docker-qbc.bintray.io/consensys/$*:$(VERSION)
	docker push consensys-docker-qbc.bintray.io/consensys/$*:$(VERSION) && touch $@

$(BUILDDIR)/.tgzpush: $(addsuffix .tar.gz.asc, $(addprefix $(BUILDDIR)/qbc-$(VERSION)-, $(BUILDS)))
	touch $(BUILDDIR)/.tgzpush

$(BUILDDIR)/qbc-$(VERSION)-%: qbc-tarballs
	gpg --detach-sign -o $@ $(subst .asc,,$@)
	curl -T $@ -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-$*.tar.gz
	curl -T $@.asc -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-$*.tar.gz.asc

circleci-macos: tarball-darwin-64
	mkdir -p $(BUILDDIR) && cd $(BUILDDIR) && tar czf $(QBC_NAME)-$(VERSION)-darwin-64.tar.gz $(addsuffix .tar.gz,$(filter %darwin-64,$(PACKAGES)))

clean:
	rm -Rf $(BUILDDIR)

check_clobber:
	@echo "You have chosen to go nuclear.  Are you sure you want to delete ALL stopped containers (Y/n)?" && read ans && [ $$ans == Y ]

clobber: check_clobber clean
	docker ps -a | awk '{ print $$1,$$2 }' | grep consensys | awk '{print $$1 }' | xargs -I {} docker container stop {} && docker system prune -a -f --volumes