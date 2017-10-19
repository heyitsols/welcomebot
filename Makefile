SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')

BINARY=welcomebot
VERSION=`cat VERSION`
BUILD_TIME=`date +%FT%T%z`

DEFAULT_SYSTEM_BINARY := $(BINARY).darwin

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	DEFAULT_SYSTEM_BINARY := $(BINARY).linux
endif

.DEFAULT_GOAL: $(BINARY)
$(BINARY): $(BINARY).darwin $(BINARY).linux
	cp $(DEFAULT_SYSTEM_BINARY) $@

$(BINARY).darwin: $(SOURCES)
	go get -v
	GOOS=darwin go build ${LDFLAGS} -o $@
	shasum $@ > $@.sha

$(BINARY).linux: $(SOURCES)
	go get -v
	docker run --rm -v ${GOPATH}/src/:/go/src -w ${BINARY} golang:1.8 go build ${LDFLAGS} -o $@
	shasum $@ > $@.sha

.PHONY: clean
clean:
	rm -f -- ${BINARY}
	rm -f -- ${BINARY}.linux
	rm -f -- ${BINARY}.darwin

# Quick command to tag a version, if that version does not already exist
# Will only tag if there are no uncommitted changes
# Designed to be run after your last commit on your branch, prior to merging
.PHONY: tag
tag:
	git diff --quiet --exit-code || (echo "You have uncommited changes in your working directory. Refusing to tag" && false)
	git diff --quiet --cached --exit-code || (echo "You have uncommited changes cached. Refusing to tag" && false)
	git tag v${VERSION}
	git push origin v${VERSION}

