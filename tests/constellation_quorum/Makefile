.DEFAULT_GOAL := test
PERMISSIONED_NODES=
GETH_KEY=
$(eval WORKDIR = $(shell cat .workdir))

.PHONY: clean stop test

.workdir:
	$(eval WORKDIR = $(shell mktemp -t constellation_quorum.XXXXX -d))
	bash config.sh $(WORKDIR) $(CURDIR)

.start: .workdir
	env WORKDIR=$(WORKDIR) docker-compose up -d
	bash waitForStart.sh
	touch .start

test: .start
	bash runTests.sh

stop:
	docker-compose down
	rm -f .start

clean:
	rm -Rf $(TMPDIR)constellation_quorum.*
	rm -f .workdir