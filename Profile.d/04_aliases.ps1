# 4. Archivo 04_aliases.ps1 (Todos tus alias)
# Atajos de comandos personalizados para mejorar tu flujo de trabajo.

# =================================================================
# ALIAS Y FUNCIONES DE DESARROLLO (PHP, NODE, GIT)
# =================================================================

# --- Git ---
# Alias para los comandos más comunes de Git, tomados del paquete:
# https://github.com/gluons/powershell-git-aliases/blob/master/aliases.md
# Con "Get-Git-Aliases" puedes ver la lista completa

# --- Composer ---
Set-Alias -Name cr -Value "composer"
Set-Alias -Name crr -Value "composer require"
Set-Alias -Name cri -Value "composer install"
Set-Alias -Name cru -Value "composer update"
Set-Alias -Name crd -Value "composer dump-autoload"

# Alias para los comandos más comunes de Artisan
Set-Alias -Name pa -Value Invoke-Artisan
Set-Alias -Name pas -Value "php artisan serve"
Set-Alias -Name tinker -Value "php artisan tinker"
Set-Alias -Name routes -Value "php artisan route:list"
Set-Alias -Name pakg -Value "php artisan key:generate"

# Migraciones y Base de Datos
Set-Alias -Name pami -Value "php artisan migrate"
Set-Alias -Name pamf -Value "php artisan migrate:fresh"
Set-Alias -Name pamr -Value "php artisan migrate:refresh --seed"
Set-Alias -Name pads -Value "php artisan db:seed"

# --- Node (NPM) ---
Set-Alias -Name npi -Value "npm install"
Set-Alias -Name ndev -Value "npm run dev"
Set-Alias -Name nprod -Value "npm run prod"
Set-Alias -Name nhot -Value "npm run hot"
Set-Alias -Name nwatch -Value "npm run watch" # 'watch' ya lo tenías, ahora es nwatch para consistencia

# --- Python ---
# Atajo para ejecutar python
Set-Alias -Name py -Value "python" -Description "Alias para el ejecutable de python"

# Atajo para crear proyecto con uv
Set-Alias -Name uvi -Value New-UvProject -Description "Crea un nuevo proyecto con uv"

# Atajo para activar el entorno virtual
Set-Alias -Name ave -Value Enter-Venv -Description "Activa el entorno virtual de python"

# Atajo para desactivar el entorno virtual
Set-Alias -Name dve -Value Exit-Venv -Description "Desactiva el entorno virtual de forma segura"

# Atajo para eliminar el entorno virtual
Set-Alias -Name rmenv -Value Remove-Venv -Description "Elimina el entorno virtual de forma segura"

# Ejecuta el linter de ruff en el directorio actual
Set-Alias -Name ruffc -Value "ruff check ." -Description "Corre el linter de Ruff"

# Formatea el código del directorio actual
Set-Alias -Name rufff -Value "ruff format ." -Description "Formatea el código con Ruff"

# Creación de los alias cortos para un acceso rápido
Set-Alias -Name pphp -Value Enter-PhpProjects -Description "Navega a $($global:DevPhpPath)"
Set-Alias -Name ppy -Value Enter-PyProjects -Description "Navega a $($global:DevPyPath)"

# =================================================================
# ALIAS PARA NAVEGACIÓN RÁPIDA
# =================================================================
# La función real es descriptiva (ej. Enter-Documents) y el alias es el atajo.
Set-Alias -Name docs    -Value Enter-Documents
Set-Alias -Name dl      -Value Enter-Downloads
Set-Alias -Name desktop -Value Enter-Desktop
Set-Alias -Name pics    -Value Enter-Pictures   # (Asegúrate que el nombre de la función coincida)
Set-Alias -Name music   -Value Enter-Music      # (etc...)
Set-Alias -Name videos  -Value Enter-Videos     # (etc...)
Set-alias -Name home    -Value Enter-UserProfile

# Unix aliases
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name rm -Value Remove-Item
Set-Alias -Name mv -Value Move-Item
Set-Alias -Name clear -Value Clear-Host
Set-Alias -Name pwd -Value Get-Location
Set-Alias -Name man -Value Get-Help
Set-Alias -Name grep -Value Select-String
Set-Alias winfetch pwshfetch-test-1

# Process management aliases
Set-Alias -Name ps -Value Get-Process
Set-Alias -Name kill -Value Stop-Process

# Un alias útil para 'which' que te dice dónde está un comando
Set-Alias -Name which -Value Get-Command

# Creamos un alias corto para la funcion de smallcow
Set-Alias -Name scow -Value Invoke-SmallCow -Description "Muestra un mensaje divertido de Small Cow"