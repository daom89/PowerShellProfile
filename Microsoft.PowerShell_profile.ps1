# =================================================================
#      PERFIL PRINCIPAL DE POWERSHELL - CARGADOR DE MÓDULOS
# =================================================================
# Este script carga todos los archivos .ps1 de la carpeta Profile.d
# en orden alfabético.

$ProfileDir = Join-Path -Path $PSScriptRoot -ChildPath "Profile.d"

# Revisa si el directorio de perfil existe
if (Test-Path $ProfileDir) {
    # Carga cada archivo de script en el ámbito actual (dot-sourcing)
    Get-ChildItem -Path $ProfileDir -Filter "*.ps1" | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
}

# Limpia la variable para no dejarla en la sesión
Remove-Variable ProfileDir -ErrorAction SilentlyContinue