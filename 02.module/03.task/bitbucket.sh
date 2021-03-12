#!/bin/bash

cd /tmp

# Test forwarded ssh-keys
echo ">>>>> Test SSH Forwarding <<<<<"
echo "$SSH_AUTH_SOCK"

# Test curl output
echo ">>>>> Test Bitbucket Answer <<<<<"
curl -Is https://bitbucket.org | head -n 1

# Test SSH connection to Bitbucket
echo ">>>>> Test Bitbucket Connection <<<<<"
ssh -T git@bitbucket.org -o StrictHostKeyChecking=no

# Clone Bitbucket repository
echo ">>>>> Clone Bitbucket Repository <<<<<"
if [ ! -d "repo" ]; then
  git clone "git@bitbucket.org:zuwarskej/devops-training.git"
fi

# Test file
cd /tmp/devops-training && cat README.md