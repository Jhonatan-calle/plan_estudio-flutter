flutter build web --wasm
# Commit and push changes to the current repository
git add .
git commit -m "ayudas del seo"
git push origin main

# Copy the build to the target directory
TARGET_DIR="../portafolio/proyectos/planEstudio"
Remove-Item -Recurse -Force "$TARGET_DIR\*"
Copy-Item -Recurse -Force "build/web/*" $TARGET_DIR #voy aqui


# Commit and push changes to the target repository
cd ../portafolio
git add .
git commit -m "plan de estudio: mejoras del SEO"
git push origin main