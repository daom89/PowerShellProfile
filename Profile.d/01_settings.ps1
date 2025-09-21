# 1. Archivo 01_settings.ps1 (Variables y Configuraciones)
# Aquí pondremos la importación de colores y cualquier variable global que quieras definir.

# Importa la paleta de colores y los iconos
. (Join-Path -Path $PSScriptRoot -ChildPath "..\Scripts\colors_icons.ps1")

# Rutas a carpetas de proyectos para un fácil mantenimiento
$global:DevPhpPath = "D:\DevProjects\PHP"
$global:DevPyPath = "D:\DevProjects\Python"