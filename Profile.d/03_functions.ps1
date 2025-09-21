# --- Artisan (PHP/Laravel) ---
function pa {
    # Pasa todos los argumentos directamente a php artisan
    php artisan $args
}

# Función para inicializar un proyecto de UV y ejecutarlo
function Start-UvProject {
    Write-Host "Paso 1: Inicializando el proyecto con 'uv init .'" -ForegroundColor Cyan
    uv init .
    Write-Host "Paso 2: Ejecutando el script 'main.py' con 'uv run'" -ForegroundColor Cyan
    uv run main.py
}

# Activa el entorno virtual (busca en ./.venv/Scripts)
function ave {
    $VenvPath = ".\.venv\Scripts\Activate.ps1"
    if (Test-Path $VenvPath) {
        . $VenvPath
        Write-Host "Entorno virtual activado." -ForegroundColor Green
    }
    else {
        Write-Warning "No se encontró el script de activación en '$VenvPath'."
    }
}

# Elimina el entorno virtual (borra la carpeta .venv)
function rmenv {
    $VenvDir = ".\.venv"
    if (Test-Path $VenvDir) {
        # Primero, intenta desactivar si el entorno está activo
        if ($env:VIRTUAL_ENV) {
            dve
        }
        Write-Host "Eliminando la carpeta del entorno virtual '$VenvDir'..."
        Remove-Item -Recurse -Force $VenvDir
        Write-Host "Entorno virtual eliminado." -ForegroundColor Yellow
    }
    else {
        Write-Warning "No se encontró la carpeta del entorno virtual '$VenvDir'."
    }
}

# =================================================================
# NAVEGACIÓN DE CARPETAS DE USUARIO
# =================================================================

# 1. Función principal y robusta que contiene toda la lógica.
function Set-ToUserFolder {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(
            'Desktop', 'MyDocuments', 'Downloads', 'MyPictures',
            'MyMusic', 'MyVideos', 'UserProfile'
        )]
        [string]$Folder
    )
    try {
        $FolderPath = '' # Inicializar la variable

        if ($Folder -eq 'Downloads') {
            # --- MÉTODO CORREGIDO ---
            # Leemos la ruta directamente del Registro de Windows. Es el método más confiable.
            $regPath = 'hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
            $regKey = '{374DE290-123F-4565-9164-39C4925E467B}'
            $rawPath = (Get-ItemProperty -Path $regPath).$regKey
            # La ruta del registro puede tener variables de entorno (ej. %USERPROFILE%), así que las expandimos.
            $FolderPath = [System.Environment]::ExpandEnvironmentVariables($rawPath)
        }
        else {
            # Para las otras carpetas, el método original sigue siendo perfecto.
            $FolderPath = [Environment]::GetFolderPath($Folder)
        }

        if (Test-Path -Path $FolderPath) {
            Set-Location -Path $FolderPath
        }
        else {
            Write-Warning "La carpeta '$Folder' ('$FolderPath') no existe o no se pudo encontrar."
        }
    }
    catch {
        Write-Error "No se pudo determinar la ruta para '$Folder'. Error: $_"
    }
}

# 2. Funciones cortas que actúan como atajos, llamando a la función principal.
# Para usar un atajo, simplemente tienes que escribir el nombre de la función o el alias 
# directamente en la terminal, sin cd antes.
function docs { Set-ToUserFolder -Folder MyDocuments }
function dl { Set-ToUserFolder -Folder Downloads }
function desktop { Set-ToUserFolder -Folder Desktop }
function pics { Set-ToUserFolder -Folder MyPictures }
function music { Set-ToUserFolder -Folder MyMusic }
function videos { Set-ToUserFolder -Folder MyVideos }
function home { Set-ToUserFolder -Folder UserProfile }

# =================================================================
# FILTRAR ANIMALES PEQUEÑOS CON COWSAY + LOLCAT
# =================================================================
function Invoke-SmallCow {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Message
    )

    $animalesPequeños = @(
        "default", "tux", "kitty", "vader-koala", "duck",
        "dragon-and-cow", "stegosaurus", "stimpy", "three-eyes", "turkey"
    )
    $animalAzar = Get-Random -InputObject $animalesPequeños

    cowsay -f $animalAzar $Message | lolcat
}

# =================================================================
# ATAJOS PARA CARPETAS DE PROYECTOS DE DESARROLLO
# =================================================================

# Función para ir a la carpeta de proyectos PHP
function Enter-PhpProjects {
    Set-Location -Path $global:DevPhpPath
}

# Función para ir a la carpeta de proyectos Python
function Enter-PyProjects {
    Set-Location -Path $global:DevPyPath
}