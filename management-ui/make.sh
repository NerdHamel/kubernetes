#!/bin/bash

if [ ! -d "template" ]; then
    echo "Creating a copy of the 'template.dist' folder for you..."
    cp -R template.dist template
fi

echo "Making the 'manifests' current in your 'template' folder..."
cp -R manifests template/manifests