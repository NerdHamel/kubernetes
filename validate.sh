#!/bin/sh

# first download kubeval, uncompress
wget https://github.com/instrumenta/kubeval/releases/download/0.9.2/kubeval-linux-amd64.tar.gz
tar xf kubeval-linux-amd64.tar.gz

# validate all files
## core
./kubeval core/config-maps/*
./kubeval core/deployments/*
./kubeval core/nlp-deployments/**/*
./kubeval core/reverse-proxy.dist/**/*
./kubeval core/secrets.dist/*
./kubeval core/services/*
./kubeval core/stateful-deployments/*
./kubeval core/volume-claims/*
./kubeval core/volumes.dist/*

## additional products
./kubeval livechat/**/*
./kubeval management-ui/**/*
./kubeval monitoring/**/*