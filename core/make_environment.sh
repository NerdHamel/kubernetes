#!/bin/bash

if [ ! -d "$1" ]; then
    echo "Creating a copy of the 'template.dist' folder for your stage..."
    cp -R template.dist $1
fi

echo "Making the 'manifests' current in your '$1' folder for your stage..."
rm -fr $1/dependencies/manifests
rm -fr $1/product/manifests
cp -R manifests $1/dependencies/manifests
cp -R manifests $1/product/manifests