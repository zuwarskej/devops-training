#!/bin/bash
cd /tmp
echo ">>>>> Test GitHub Connection <<<<<"
ssh -T git@github.com
echo ">>>>> Clone Repository <<<<<"
if [ ! -d "repo" ]; then
  git clone "git@github.com:zuwarskej/devops-training.git"
fi
cd /tmp/devops-training/02.module && cat 02.module.txt