
VERSION := $(shell git describe --tags)
BUILD := $(shell git rev-parse --short HEAD)
PROJECTNAME := $(shell basename "$(PWD)")

# Go related variables.
GOBASE := $(shell pwd)
GOPATH := $(GOBASE)/vendor:$(GOBASE)
GOBIN := $(GOBASE)/bin
GOFILES := $(wildcard *.go)

# Use linker flags to provide version/build settings
LDFLAGS=-ldflags "-X=main.Version=$(VERSION) -X=main.Build=$(BUILD)"

# Redirect error output to a file, so we can show it in development mode.
STDERR := /tmp/.$(PROJECTNAME)-stderr.txt

# PID file will keep the process id of the server
PID := /tmp/.$(PROJECTNAME).pid

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

## install: Install missing dependencies. Runs `go get` internally. e.g; make install get=github.com/foo/bar
install: go-get

## test: Run all testcases.
test: go-test

## lint: Check for Syntax and Sematics error
lint: go-lint

## start: Start in development mode. Auto-starts when code changes.
start:
	@bash -c "trap 'make stop' EXIT; $(MAKE) clean go-lint compile start-server watch run='make clean go-lint compile start-server'"

## stop: Stop development mode.
stop: stop-server

start-server: stop-server
	@echo "  >  $(PROJECTNAME) is available"
	@-$(GOBIN)/$(PROJECTNAME) 2>&1 & echo $$! > $(PID)
	@cat $(PID) | sed "/^/s/^/  \>  PID: /"

stop-server:
	@echo "  >  Stop Server"
	@-touch $(PID)
	@-kill `cat $(PID)` 2> /dev/null || true
	@-rm $(PID)

## watch: Run given command when code changes. e.g; make watch run="echo 'hey'"

watch:
	@echo "  >  About to watch"
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) yolo -i . -e vendor -e bin -c "$(run)"


restart-server: stop-server start-server

## compile: Compile the binary.
compile:
	@-touch $(STDERR)
	@-rm $(STDERR)
	@-$(MAKE) -s go-compile 2> $(STDERR)
	@cat $(STDERR) | sed -e '1s/.*/\nError:\n/'  | sed 's/make\[.*/ /' | sed "/^/s/^/     /" 1>&2

## exec: Run given command, wrapped with custom GOPATH. e.g; make exec run="go test ./..."

exec:
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) $(run)

## clean: Clean build files. Runs `go clean` internally.

clean:
	@-rm $(GOBIN)/$(PROJECTNAME) 2> /dev/null
	@-$(MAKE) go-clean

go-compile: go-get go-build

go-build:
	@echo "  >  Building binary..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build  $(LDFLAGS) -o $(GOBIN)/$(PROJECTNAME) $(GOFILES)

go-test:
	@echo " > Running testcases"
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go install
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go test ./... -v

go-generate:
	@echo "  >  Generating dependency files..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go generate $(generate)

go-lint:
	@echo "  >  Check Lint ..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) golangci-lint run ./...

go-get:
	@echo "  >  Checking if there is any missing dependencies..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go get $(get)

go-install:
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go install $(GOFILES)

go-clean:
	@echo "  >  Cleaning build cache"
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go clean

docker-build:
	@echo "  >  Building docker..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) docker build --tag=web-app-$(app_env) --build-arg app_env=$(app_env) --build-arg app_port=$(app_port) .

docker-push:
	@echo "  >  Push to docker Registry ..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) docker login --username nofsky
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) docker image tag web-app-$(app_env) nofsky/web-app-$(app_env)
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) docker push  nofsky/web-app-$(app_env)

docker-run:
	@echo "   > Running docker ..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) docker run -p $(app_port):$(app_port) web-app-$(app_env)

.PHONY: help
all: help
help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo