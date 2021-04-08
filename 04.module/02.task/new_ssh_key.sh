#!/bin/bash

# Generate RSA SSH-key
echo "Enter your email"
read -r email
ssh-keygen -t rsa -b 4096 \
 -f ~/.ssh/id_rsa_$(whoami)_$(date +%Y-%m-%d) \
 -C "$email"