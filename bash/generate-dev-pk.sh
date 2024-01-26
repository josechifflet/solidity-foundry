#!/usr/bin/env bash

# Generate a private key
private_key=$(openssl rand -hex 32)
echo "Private Key: $private_key"

# Generate Ethereum address using the JavaScript script
node ./bash/generate_address.js $private_key
