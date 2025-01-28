#!/bin/bash

# Commit and push changes to the current repository
git add .
git commit -m "ayudas del seo"
git push origin main

# Copy the build to the target directory
TARGET_DIR="../portafolio/proyectos/planEstudio"
rm -rf $TARGET_DIR/*
cp -r build/web/* $TARGET_DIR/

# Commit and push changes to the target repository
cd ../portafolio
git add .
git commit -m "plan de estudio: mejoras del SEO"
git push origin main