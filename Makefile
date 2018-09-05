TESSERA_VERSION=0.6
QUORUM_VERSION=v2.0.3-grpc
CRUX_VERSION=v1.0.1
GOOS=darwin
GOARCH=386

.PHONY: all
	
all: linux-386 darwin-64
	
	
linux-386: build/tessera-$(TESSERA_VERSION).tar.gz build/quorum-$(QUORUM_VERSION)-linux-386.tar.gz # build/crux-$(CRUX_VERSION)-linux-386.tar.gz
darwin-64: build/tessera-$(TESSERA_VERSION).tar.gz build/quorum-$(QUORUM_VERSION)-darwin-64.tar.gz build/crux-$(CRUX_VERSION)-darwin-64.tar.gz

tessera-$(TESSERA_VERSION):
	git clone --branch tessera-$(TESSERA_VERSION) --depth 1 https://github.com/jpmorganchase/tessera.git tessera-$(TESSERA_VERSION)

tessera-$(TESSERA_VERSION)/target/tessera-$(TESSERA_VERSION).jar: tessera-$(TESSERA_VERSION)
	cd tessera-$(TESSERA_VERSION) && mvn package

build/tessera-$(TESSERA_VERSION).tar.gz: tessera-$(TESSERA_VERSION)/tessera-app/target/tessera-app-$(TESSERA_VERSION)-app.jar
	mkdir -p build
	tar cf build/tessera-$(TESSERA_VERSION).tar -C docs/tessera .
	tar rf build/tessera-$(TESSERA_VERSION).tar -C tessera-$(TESSERA_VERSION)/tessera-app/target tessera-app-$(TESSERA_VERSION)-app.jar
	gzip build/tessera-$(TESSERA_VERSION).tar
	
quorum-$(QUORUM_VERSION)-darwin-64:
	git clone --branch $(QUORUM_VERSION) --depth 1 https://github.com/ConsenSys/quorum.git quorum-$(QUORUM_VERSION)-darwin-64
	
quorum-$(QUORUM_VERSION)-darwin-64/build/bin/geth: quorum-$(QUORUM_VERSION)-darwin-64
	cd quorum-$(QUORUM_VERSION)-darwin-64 && make
	
build/quorum-$(QUORUM_VERSION)-darwin-64.tar.gz: quorum-$(QUORUM_VERSION)-darwin-64/build/bin/geth
	mkdir -p build
	tar cf build/quorum-$(QUORUM_VERSION)-darwin-64.tar -C docs/quorum .
	tar rf build/quorum-$(QUORUM_VERSION)-darwin-64.tar -C quorum-$(QUORUM_VERSION)-darwin-64/build/bin geth
	gzip build/quorum-$(QUORUM_VERSION)-darwin-64.tar
	
quorum-$(QUORUM_VERSION)-linux-386:
	git clone --branch $(QUORUM_VERSION) --depth 1 https://github.com/ConsenSys/quorum.git quorum-$(QUORUM_VERSION)-linux-386
	
quorum-$(QUORUM_VERSION)-linux-386/build/bin/geth: quorum-$(QUORUM_VERSION)-linux-386
	cd quorum-$(QUORUM_VERSION)-linux-386 && make
	
build/quorum-$(QUORUM_VERSION)-linux-386.tar.gz: quorum-$(QUORUM_VERSION)-linux-386/build/bin/geth
	mkdir -p build
	tar cf build/quorum-$(QUORUM_VERSION)-linux-386.tar -C docs/quorum .
	tar rf build/quorum-$(QUORUM_VERSION)-linux-386.tar -C quorum-$(QUORUM_VERSION)-linux-386/build/bin geth
	gzip build/quorum-$(QUORUM_VERSION)-linux-386.tar
	
crux-$(CRUX_VERSION):
	git clone --branch $(CRUX_VERSION) --depth 1 https://github.com/blk-io/crux.git crux-$(CRUX_VERSION)
	cat chimera-api-crux-v1.0.1.patch >> crux-$(CRUX_VERSION)/Gopkg.toml
	
crux-$(CRUX_VERSION)/bin/crux: crux-$(CRUX_VERSION)
	cd crux-$(CRUX_VERSION) && make setup && make
	
build/crux-$(CRUX_VERSION)-darwin-64.tar.gz: crux-$(CRUX_VERSION)/bin/crux
	mkdir -p build
	tar cf build/crux-$(CRUX_VERSION)-darwin-64.tar -C docs/crux .
	tar rf build/crux-$(CRUX_VERSION)-darwin-64.tar -C crux-$(CRUX_VERSION)/bin crux
	gzip build/crux-$(CRUX_VERSION)-darwin-64.tar
	
crux-$(CRUX_VERSION)-linux-386:
	git clone --branch $(CRUX_VERSION) --depth 1 https://github.com/blk-io/crux.git crux-$(CRUX_VERSION)-linux-386
	cat chimera-api-crux-v1.0.1.patch >> crux-$(CRUX_VERSION)-linux-386/Gopkg.toml
	
crux-$(CRUX_VERSION)-linux-386/bin/crux: crux-$(CRUX_VERSION)-linux-386
	cd crux-$(CRUX_VERSION)-linux-386 && make setup && env GOOS=linux GOARCH=386 make build

build/crux-$(CRUX_VERSION)-linux-386.tar.gz: crux-$(CRUX_VERSION)-linux-386/bin/crux
	mkdir -p build
	tar cf build/crux-$(CRUX_VERSION)-linux-386.tar -C docs/crux .
	tar rf build/crux-$(CRUX_VERSION)-linux-386.tar -C crux-$(CRUX_VERSION)/bin crux
	gzip build/crux-$(CRUX_VERSION)-linux-386.tar