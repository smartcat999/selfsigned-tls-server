#!/bin/bash

set -e

usage() {
    cat <<EOF
Generate certificate suitable for use with an https service.
This script uses openssl command to a generate a self-signed
certificate for use with local https
services. This requires permissions to create and approve CSR.
usage: ${0} [OPTIONS]
The following flags are required.
       --CN          CommonName of certs.
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case ${1} in
        --CN)
            CN="$2"
            shift
            ;;
        *)
            usage
            ;;
    esac
    shift
done

if [ ! -x "$(command -v openssl)" ]; then
    echo "openssl not found"
    exit 1
fi

# csrName=${service}.${namespace}
CERTSDIR="ssl"

if [ ! -d ${CERTSDIR} ]; then
  mkdir ${CERTSDIR}
fi

echo "creating certs in certsdir ${CERTSDIR} "

cat > ${CERTSDIR}/san.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
countryName = CN
countryName_default = CN
stateOrProvinceName = HB
stateOrProvinceName_default = HB
organizationalUnitName = WH
organizationalUnitName_default = WH
commonName = ${CN}
commonName_default = ${CN}

[v3_req]
basicConstraints = CA:TRUE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${CN}
IP.1 = 127.0.0.1
EOF

# generate ca
openssl req -x509 -newkey rsa:4096 -keyout ${CERTSDIR}/ca.key -out ${CERTSDIR}/ca.crt -days 10000 -config ${CERTSDIR}/san.cnf -noenc -batch

# generate server.csr
openssl req -new -keyout ${CERTSDIR}/server.key -out ${CERTSDIR}/server.csr -config ${CERTSDIR}/san.cnf -noenc -batch

# create server.crt
openssl x509 -req -in ${CERTSDIR}/server.csr -CA ${CERTSDIR}/ca.crt -CAkey ${CERTSDIR}/ca.key \
  -CAcreateserial -out ${CERTSDIR}/server.crt -days 10000 -extensions v3_req -extfile ${CERTSDIR}/san.cnf
