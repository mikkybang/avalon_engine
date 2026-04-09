build-engine:
	cd ./avalon/ && zig build

build-sandbox:
	cd ./sandbox/ && zig build

run-sandbox:
	./sandbox/zig-out/bin/sandbox
