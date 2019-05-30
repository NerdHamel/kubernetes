#!/bin/sh

# validate core files
kubeval core/config-maps/*
kubeval core/deployments/*
kubeval core/nlp-deployments/**/*
kubeval core/reverse-proxy.dist/**/*
kubeval core/secrets.dist/*
kubeval core/services/*
kubeval core/stateful-deployments/*
kubeval core/volume-claims/*
kubeval core/volumes.dist/*

# validate livechat (handover / agent ui)
kubeval livechat/**/*

# validate management ui
kubeval management-ui/**/*

# validate monitoring files
kubeval monitoring/**/*