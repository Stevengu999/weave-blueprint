PKG = github.com/loomnetwork/etherboy-core
PROTOC = protoc --plugin=./protoc-gen-gogo -Ivendor -Isrc -I/usr/local/include

.PHONY: all clean test lint deps proto

all: internal-plugin blueprint-cli etherboy-indexer

internal-plugin: blueprint.so

blueprint.so: proto
	mkdir -p build/contracts
	go build -buildmode=plugin -o build/contracts/$@ src/blueprint.go

blueprintcli: proto
	mkdir -p build/cmds
	go build -buildmode=plugin -o build/cmds/blueprint.so src/cmd-plugins/create-tx/plugin/create_tx.go

blueprint-indexer:
	go build src/tools/cli/indexer

protoc-gen-gogo:
	go build github.com/gogo/protobuf/protoc-gen-gogo


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
		github.com/pkg/errors

clean:
	go clean
	rm -f \
		protoc-gen-gogo \
		src/types/types.pb.go \
		testdata/test.pb.go \
		run/contracts/etherboy.so \
		run/cmds/etherboyclu.so