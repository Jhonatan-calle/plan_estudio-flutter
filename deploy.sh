#!/bin/bash

# Construir el proyecto Flutter para web
#flutter build web

# Copiar los archivos generados al repositorio de portafolio
rsync -av -r /build/web/*  ../portafolio/planEstudio


# Cambia de directorio al repositorio de GitHub Pages del portafolio
cd ../portafolio/

# Agrega, commitea y sube los cambios a GitHub
git add .
git commit -m "Update project deployment"
git push origin main  # Cambia 'main' por la rama de GitHub Pages si es necesario
