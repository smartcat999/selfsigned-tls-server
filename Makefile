CN ?= smartcatio.com

generate-certs:
	./hack/generate_certs.sh --CN ${CN}

run:
	cargo run src/main.rs

build:
	cargo build

release:
	cargo build --release

clean:
	cargo clean
