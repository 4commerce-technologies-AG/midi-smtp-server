#!/bin/bash

# create keyfiles for CA and CERT
openssl genrsa -out test-cert.ca.key.pem 4096
openssl genrsa -out test-cert.srv.key.pem 4096

# create a new CA
openssl req -new -x509 -key test-cert.ca.key.pem -days 9999 -out test-cert.ca.pem -config <( cat test-cert.ca.conf )

# create a new Service CSR
openssl req -new -key test-cert.srv.key.pem -out test-cert.srv.csr -config <( cat test-cert.srv.conf )

# sign the Service CSR with CA
openssl x509 -req -in test-cert.srv.csr -CA test-cert.ca.pem -CAkey test-cert.ca.key.pem -CAcreateserial -out test-cert.srv.pem -days 9999 -extensions 'req_ext' -extfile <(cat test-cert.srv.conf)

# prepare a full chain PEM file
cat test-cert.srv.pem test-cert.ca.pem > test-cert.srv.chain.pem

# prepare a full chain PEM file with KEY
cat test-cert.srv.key.pem test-cert.srv.pem test-cert.ca.pem > test-cert.srv.chain-and-key.pem

# create a simple Service certificate
openssl x509 -req -in test-cert.srv.csr -signkey test-cert.srv.key.pem -out test-cert.srv.simple.pem -days 9999 -extensions 'req_ext' -extfile <(cat test-cert.srv.conf)

# cleanup all unused files
rm -f test-cert.ca.pem test-cert.ca.key.pem test-cert.srl
rm -f test-cert.srv.csr test-cert.srv.pem
