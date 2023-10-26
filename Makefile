CN ?= smartcatio.com

generate-certs:
	./hack/generate_certs.sh --CN ${CN}
