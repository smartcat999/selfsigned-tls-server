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

[ -z "${service}" ] && service=webhook-service
[ -z "${namespace}" ] && namespace=default

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

# create cakey
openssl genrsa -out ${CERTSDIR}/ca.key 2048

# create ca.crt
openssl req -x509 -new -nodes -key ${CERTSDIR}/ca.key -subj "/C=CN/ST=HB/O=QC/CN=${CN}" -sha256 -days 10000 -out ${CERTSDIR}/ca.crt

# create server.key
openssl genrsa -out ${CERTSDIR}/server.key 2048

# create server.crt
openssl req -new -sha256 -key ${CERTSDIR}/server.key -subj "/C=CN/ST=HB/O=QC/CN=${CN}" -out ${CERTSDIR}/server.csr
openssl x509 -req -in ${CERTSDIR}/server.csr -CA ${CERTSDIR}/ca.crt -CAkey ${CERTSDIR}/ca.key -CAcreateserial -out ${CERTSDIR}/server.crt -days 10000 -sha256
