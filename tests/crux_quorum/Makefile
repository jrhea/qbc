.DEFAULT_GOAL := test
PERMISSIONED_NODES=
GETH_KEY=
$(eval WORKDIR = $(shell cat .workdir))

.PHONY: clean stop test

.workdir:
	$(eval WORKDIR = $(shell mktemp -t crux_quorum.XXXXX -d))
	bash config.sh $(WORKDIR) $(CURDIR)

.start: .workdir
	env WORKDIR=$(WORKDIR) docker-compose up -d
	bash waitForStart.sh
	touch .start

.check_up: .start
	$(eval OK = 200)
	$(eval HTTP_STATUS = $(shell curl -s -o /dev/null -w "%{http_code}" -X POST "http://localhost:19012/upcheck"))
	@if [ "$(HTTP_STATUS)" -eq "$(OK)" ]; then \
		echo "upcheck succeeded with HTTP_STATUS: $(HTTP_STATUS)"; \
		touch .check_up; \
	else \
		echo "upcheck failed with HTTP_STATUS: $(HTTP_STATUS)" 1>&2; \
		exit 1; \
	fi

test: .check_up
	bash runTests.sh

stop:
	docker-compose down
	rm -f .start

clean:
	rm -Rf $(TMPDIR)crux_quorum.*
	rm -f .workdir

