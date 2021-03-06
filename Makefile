.PHONY: all
all: build fmt vet lint test

ALL_PACKAGES=$(shell go list ./... | grep -v "vendor")

APP_EXECUTABLE="out/iap_auth"
COMMIT_HASH=$(shell git rev-parse --verify head | cut -c-1-8)
BUILD_DATE=$(shell date +%Y-%m-%dT%H:%M:%S%z)

setup:
	go get -u github.com/golang/lint/golint

compile:
	mkdir -p out/
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o $(APP_EXECUTABLE) .
	#go build -o $(APP_EXECUTABLE) -ldflags "-X main.Build=$(BUILD_DATE) -X main.Commit=$(COMMIT_HASH) -s -w"

build: compile fmt vet lint

install:
	go install ./...

fmt:
	go fmt ./...

vet:
	go vet ./...

lint:
	@if [[ `golint $(All_PACKAGES) | { grep -vwE "exported (var|function|method|type|const) \S+ should have comment" || true; } | wc -l | tr -d ' '` -ne 0 ]]; then \
		golint $(ALL_PACKAGES) | { grep -vwE "exported (var|function|method|type|const) \S+ should have comment" || true; }; \
		exit 2; \
	fi;

test: copy-config
	go test ./...

test-cover-html:
	@echo "mode: count" > coverage-all.out
	$(foreach pkg, $(ALL_PACKAGES),\
	go test -coverprofile=coverage.out -covermode=count $(pkg);\
	tail -n +2 coverage.out >> coverage-all.out;)
	go tool cover -html=coverage-all.out -o out/coverage.html

copy-config:
	cp iap.conf.toml.sample iap.conf.toml

clean:
	go clean && rm -rf ./vendor ./build

docker-up:
	docker-compose up -d

start: docker-up compile
	$(APP_EXECUTABLE) server

