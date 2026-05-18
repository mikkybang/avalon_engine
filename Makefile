build-engine:
	cd ./avalon/ && ~/dev/zig-x86_64-linux-0.15.2/zig build

build-sandbox:
	cd ./sandbox/ && ~/dev/zig-x86_64-linux-0.15.2/zig  build

run-sandbox:
	./sandbox/zig-out/bin/sandbox

dev: build-sandbox run-sandbox
