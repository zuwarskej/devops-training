#!/bin/bash

cd /tmp

# Test forwarded ssh-keys
echo ">>>>> Test SSH Forwarding <<<<<"
echo "$SSH_AUTH_SOCK"

# Test curl output
echo ">>>>> Test GitHub Answer <<<<<"
curl -Is https://github.com | head -n 1

# Test SSH connection to GitHub
echo ">>>>> Test GitHub Connection <<<<<"
ssh -T git@github.com -o StrictHostKeyChecking=no

# Clone GitHub repository
echo ">>>>> Clone GitHub Repository <<<<<"
if [ ! -d "repo" ]; then
  git clone "git@github.com:zuwarskej/devops-training.git"
fi

# Test file
cd /tmp/devops-training/02.module && cat 02.module.txt