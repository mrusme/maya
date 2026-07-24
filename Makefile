.PHONY: all help test vet build db\:drop run

PWD := $(shell pwd)

GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)

NAME := maya
PREFIX := xn--gckvb8fzb.com/
PROJECT := $(PREFIX)$(NAME)
VERSION := $(shell git describe --tags 2>/dev/null || echo "dev")
COMMIT := $(shell git rev-parse --verify HEAD 2>/dev/null || echo "none")
DATE := $(shell date)

DB ?= maya_dev

all: build

help: ## print this help
	@grep -E '^[a-zA-Z_:\\-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

test: ## test
	go test -v ./...

vet: ## vet
	go vet ./...

build: ## build
	@echo "Building with the following parameters:"
	@echo "VERSION = $(VERSION)"
	@echo "COMMIT  = $(COMMIT)"
	@echo "DATE    = $(DATE)"
	@CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags "-s -w -X \"${PROJECT}/runtime.Version=${VERSION}\" -X \"${PROJECT}/runtime.Commit=${COMMIT}\" -X \"${PROJECT}/runtime.Date=${DATE}\"" -o $(PWD)/build/$(NAME)

db\:drop: ## clear development database (drop all tables and content, keep the database)
	psql -h localhost -p 5432 -U postgres -d $(DB) -c "DROP SCHEMA public CASCADE;" -c "CREATE SCHEMA public;"

run: build ## build and run
	./build/$(NAME) -c "file://$(PWD)/maya.toml"
