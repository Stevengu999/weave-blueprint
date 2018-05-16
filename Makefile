PKG = github.com/loomnetwork/weave-blueprint
PROTOC = protoc --plugin=./protoc-gen-gogo -Ivendor -Isrc -I/usr/local/include

.PHONY: all clean test lint deps proto

all: internal-plugin

internal-plugin: build/contracts/blueprint.0.0.1

build/contracts/blueprint.0.0.1: proto
	mkdir -p build/contracts
	go build -o $@ src/blueprint.go

protoc-gen-gogo:
	go build github.com/gogo/protobuf/protoc-gen-gogo

cli:
	go build -o build/blueprint src/cli/main.go

%.pb.go: %.proto protoc-gen-gogo
	$(PROTOC) --gogo_out=src $<

proto: src/types/types.proto src/types/types.pb.go

test: proto
	go test $(PKG)/...

lint:
	golint ./...

deps:
	go get \
		github.com/gogo/protobuf/jsonpb \
		github.com/gogo/protobuf/proto \
		github.com/spf13/cobra \
		github.com/gomodule/redigo/redis \
		github.com/loomnetwork/go-loom \
		github.com/hashicorp/go-plugin \
		github.com/pkg/errors \
		github.com/grpc-ecosystem/go-grpc-prometheus \
		go get github.com/go-kit/kit/log

clean:
	go clean
	rm -f \
		protoc-gen-gogo \
		src/types/types.pb.go \
		testdata/test.pb.go \

