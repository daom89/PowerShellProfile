# 3. Archivo 03_functions.ps1 (Todas tus funciones)
# Funciones personalizadas para tareas comunes y flujos de trabajo.

# --- Artisan (PHP/Laravel) ---
function Invoke-Artisan {
    <#
    .SYNOPSIS
        Ejecuta un comando de php artisan, pasando todos los argumentos restantes.
    .EXAMPLE
        Invoke-Artisan make:model User -m
    #>
    [CmdletBinding()] # Habilita características avanzadas como -Verbose
    param(
        # El comando principal de artisan (ej: 'make:model', 'route:list')
        # Es obligatorio y es el primer argumento (Posición 0)
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Command,

        # Captura TODOS los demás argumentos que se pasen a la función
        # y los guarda en el array $RemainingArgs
        [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
        [string[]]$RemainingArgs
    )

    # El bloque begin se ejecuta una vez al principio. Ideal para validaciones.
    begin {
        # Validar si 'php' está disponible en el sistema
        if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
            throw "El comando 'php' no se encuentra en tu PATH. ¿Está instalado PHP correctamente?"
        }
    }

    # El bloque process es el corazón de la función.
    process {
        # Muestra el comando que se va a ejecutar si usas el flag -Verbose
        Write-Verbose "Ejecutando: php artisan $Command $RemainingArgs"
        
        # Ejecuta el comando de artisan, pasando el comando principal y los argumentos restantes
        & php artisan $Command $RemainingArgs
    }
}

# Registra un autocompletador para el parámetro -Command de nuestra función
Register-ArgumentCompleter -CommandName Invoke-Artisan -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    # Si 'artisan' existe, pide la lista de todos sus comandos en formato JSON
    if ($cachedCommands = Get-Command "artisan" -ErrorAction SilentlyContinue) {
        # Ejecuta 'php artisan list' y convierte la salida a objetos de PowerShell
        $commandList = php artisan list --format=json | ConvertFrom-Json
        
        # Filtra los comandos disponibles que coincidan con lo que el usuario ha escrito
        $commandList.commands.name | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            # Devuelve el nombre del comando como una sugerencia de autocompletado
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}


# Función para inicializar un proyecto de UV, opcionalmente en una nueva carpeta, y abrirlo en VS Code
function New-UvProject {
    <#
    .SYNOPSIS
        Crea un nuevo proyecto de Python con 'uv', opcionalmente en una nueva carpeta.
    .EXAMPLE
        New-UvProject -ProjectName mi-app-genial
        # Crea la carpeta 'mi-app-genial', entra, inicializa uv y abre VS Code.
    .EXAMPLE
        New-UvProject
        # Inicializa uv en la carpeta actual y abre VS Code.
    #>
    [CmdletBinding()]
    param(
        # Parámetro posicional y opcional para el nombre del proyecto/carpeta
        [Parameter(Position = 0)]
        [string]$ProjectName
    )

    try {
        # --- PASO 1: PREPARAR EL DIRECTORIO ---
        if (-not [string]::IsNullOrEmpty($ProjectName)) {
            # Si se proporcionó un nombre de proyecto...
            if (Test-Path -Path $ProjectName) {
                # ...pero la carpeta ya existe, detener y advertir.
                throw "La carpeta '$ProjectName' ya existe. Operación cancelada."
            }
            Write-Host "📂 Creando y entrando en el directorio '$ProjectName'..." -ForegroundColor Cyan
            New-Item -ItemType Directory -Name $ProjectName | Out-Null
            Set-Location -Path $ProjectName
        }

        # --- PASO 2: INICIALIZAR EL PROYECTO UV ---
        Write-Host "🚀 Inicializando el proyecto con 'uv init'..." -ForegroundColor Cyan
        uv init .

        # Creamos un 'main.py' de ejemplo para que 'uv run' funcione.
        $mainPyContent = 'print("¡Hola desde tu nuevo proyecto uv!")'
        Set-Content -Path "main.py" -Value $mainPyContent
        
        # --- PASO 3: EJECUTAR Y ABRIR EN VS CODE ---
        Write-Host "🏃 Ejecutando el script 'main.py' por primera vez..." -ForegroundColor Cyan
        uv run main.py

        Write-Host "💻 Abriendo el proyecto en Visual Studio Code..." -ForegroundColor Cyan
        code .

    }
    catch {
        # Captura cualquier error (como la carpeta que ya existe) y lo muestra en rojo.
        Write-Error $_
    }
}

# Activa de forma inteligente un entorno virtual de Python buscando hacia arriba en el árbol de directorios.
function Enter-Venv {
    [CmdletBinding()]
    param(
        # Permite especificar un nombre de venv si no es uno de los comunes.
        [Parameter(Position=0)]
        [string]$Name
    )

    $currentPath = Get-Location
    $VenvPath = $null

    # 1. BÚSQUEDA DEL ENTORNO VIRTUAL
    if (-not [string]::IsNullOrEmpty($Name)) {
        # Si el usuario especifica un nombre, búscalo solo en la carpeta actual.
        $TestPath = Join-Path -Path $currentPath -ChildPath "$Name\Scripts\Activate.ps1"
        if (Test-Path $TestPath) {
            $VenvPath = $TestPath
        }
    }
    else {
        # Si no se especifica nombre, inicia la búsqueda inteligente.
        $CommonVenvNames = '.venv', 'venv', 'env'
        while ($currentPath -ne $null) {
            foreach ($venvName in $CommonVenvNames) {
                $TestPath = Join-Path -Path $currentPath -ChildPath "$venvName\Scripts\Activate.ps1"
                if (Test-Path $TestPath) {
                    $VenvPath = $TestPath
                    break # Sal del bucle foreach
                }
            }
            if ($VenvPath) { break } # Sal del bucle while

            # Sube al directorio padre para la siguiente iteración
            $parent = (Get-Item $currentPath).Parent
            if ($parent) {
                $currentPath = $parent.FullName
            } else {
                $currentPath = $null # Llegamos a la raíz
            }
        }
    }

    # 2. ACTIVACIÓN DEL ENTORNO
    if ($VenvPath) {
        . $VenvPath
        Write-Host "✅ Entorno virtual activado desde '$VenvPath'" -ForegroundColor Green
    }
    else {
        Write-Warning "No se encontró un entorno virtual (.venv, venv, env) en esta ubicación o sus superiores."
    }
}

# Desactiva un entorno virtual de Python si hay uno activo.
function Exit-Venv {
    # La variable de entorno VIRTUAL_ENV es el indicador universal de un venv activo.
    if ($env:VIRTUAL_ENV) {
        deactivate
        Write-Host "✅ Entorno virtual desactivado." -ForegroundColor Green
    }
    else {
        Write-Warning "No hay ningún entorno virtual activo para desactivar."
    }
}

# Elimina de forma segura e inteligente un entorno virtual de Python.
function Remove-Venv {
    [CmdletBinding(SupportsShouldProcess = $true)] # <-- HABILITA LA CONFIRMACIÓN Y -WhatIf
    param(
        # Permite especificar un nombre de venv si no es uno de los comunes.
        [Parameter(Position=0)]
        [string]$Name
    )

    # 1. BÚSQUEDA DEL ENTORNO VIRTUAL (misma lógica que Enter-Venv)
    $VenvDirPath = $null
    $searchPath = Get-Location

    if (-not [string]::IsNullOrEmpty($Name)) {
        $TestPath = Join-Path -Path $searchPath -ChildPath $Name
        if (Test-Path $TestPath) { $VenvDirPath = $TestPath }
    }
    else {
        $CommonVenvNames = '.venv', 'venv', 'env'
        while ($searchPath -ne $null) {
            foreach ($venvName in $CommonVenvNames) {
                $TestPath = Join-Path -Path $searchPath -ChildPath $venvName
                if (Test-Path $TestPath) {
                    $VenvDirPath = $TestPath
                    break
                }
            }
            if ($VenvDirPath) { break }
            $parent = (Get-Item $searchPath).Parent
            $searchPath = if ($parent) { $parent.FullName } else { $null }
        }
    }

    # 2. LÓGICA DE ELIMINACIÓN SEGURA
    if ($VenvDirPath) {
        # Esta es la línea clave: Pide confirmación al usuario antes de continuar.
        # También habilita el funcionamiento de -WhatIf.
        if ($PSCmdlet.ShouldProcess($VenvDirPath, "Eliminar entorno virtual")) {

            # Comprueba si el venv a eliminar es el que está activo actualmente.
            if ($env:VIRTUAL_ENV -and ((Resolve-Path $env:VIRTUAL_ENV).Path -eq (Resolve-Path $VenvDirPath).Path)) {
                dve
                Write-Host "↪️ Entorno virtual activo ha sido desactivado." -ForegroundColor Cyan
            }

            Remove-Item -Recurse -Force -Path $VenvDirPath
            Write-Host "✅ Entorno virtual '$VenvDirPath' ha sido eliminado." -ForegroundColor Green
        }
    }
    else {
        Write-Warning "No se encontró un entorno virtual para eliminar."
    }
}

# =================================================================
# NAVEGACIÓN DE CARPETAS DE USUARIO
# =================================================================

# 1. Función principal y robusta que contiene toda la lógica.
# Acepta un subdirectorio opcional para una navegación más profunda.
function Set-ToUserFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'Desktop', 'MyDocuments', 'Downloads', 'MyPictures',
            'MyMusic', 'MyVideos', 'UserProfile'
        )]
        [string]$Folder,

        # Nuevo parámetro opcional para el subdirectorio.
        # Es posicional, por lo que puedes escribir 'docs mi/ruta' directamente.
        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [string]$Subfolder
    )

    try {
        $baseFolderPath = '' # Inicializar la variable

        # --- OBTENER RUTA BASE (Lógica original sin cambios) ---
        if ($Folder -eq 'Downloads') {
            $regPath = 'hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
            $regKey = '{374DE290-123F-4565-9164-39C4925E467B}'
            $rawPath = (Get-ItemProperty -Path $regPath).$regKey
            $baseFolderPath = [System.Environment]::ExpandEnvironmentVariables($rawPath)
        }
        else {
            $baseFolderPath = [Environment]::GetFolderPath($Folder)
        }

        # --- CONSTRUIR RUTA FINAL ---
        # Si se proporcionó un subdirectorio, lo unimos a la ruta base.
        # En caso contrario, la ruta final es simplemente la ruta base.
        $targetPath = if (-not [string]::IsNullOrEmpty($Subfolder)) {
            Join-Path -Path $baseFolderPath -ChildPath $Subfolder
        } else {
            $baseFolderPath
        }

        # --- NAVEGAR Y VALIDAR ---
        if (Test-Path -Path $targetPath) {
            Set-Location -Path $targetPath
            # Opcional: Muestra la ruta a la que te has movido.
            Write-Host "➡️  Navegando a '$($targetPath)'" -ForegroundColor Green
        }
        else {
            # El mensaje de advertencia ahora es más específico.
            Write-Warning "La ruta '$targetPath' no existe o no se pudo encontrar."
        }
    }
    catch {
        Write-Error "No se pudo determinar la ruta para '$Folder'. Error: $_"
    }
}

# 2. Funciones cortas (atajos) actualizadas para pasar el subdirectorio.
# Cada atajo ahora es una función completa que acepta un parámetro y lo reenvía.
function Enter-Documents {
    [CmdletBinding()]
    param([Parameter(Position=0, ValueFromPipeline=$true)][string]$Subfolder)
    Set-ToUserFolder -Folder MyDocuments -Subfolder $Subfolder
}

function Enter-Downloads {
    [CmdletBinding()]
    param([Parameter(Position=0, ValueFromPipeline=$true)][string]$Subfolder)
    Set-ToUserFolder -Folder Downloads -Subfolder $Subfolder
}

function Enter-Desktop {
    [CmdletBinding()]
    param([Parameter(Position=0, ValueFromPipeline=$true)][string]$Subfolder)
    Set-ToUserFolder -Folder Desktop -Subfolder $Subfolder
}

function Enter-Pictures {
    [CmdletBinding()]
    param([Parameter(Position=0, ValueFromPipeline=$true)][string]$Subfolder)
    Set-ToUserFolder -Folder MyPictures -Subfolder $Subfolder
}

function Enter-Music {
    [CmdletBinding()]
    param([Parameter(Position=0, ValueFromPipeline=$true)][string]$Subfolder)
    Set-ToUserFolder -Folder MyMusic -Subfolder $Subfolder
}

function Enter-Videos {
    [CmdletBinding()]
    param([Parameter(Position=0, ValueFromPipeline=$true)][string]$Subfolder)
    Set-ToUserFolder -Folder MyVideos -Subfolder $Subfolder
}

function Enter-UserProfile {
    [CmdletBinding()]
    param([Parameter(Position=0, ValueFromPipeline=$true)][string]$Subfolder)
    Set-ToUserFolder -Folder UserProfile -Subfolder $Subfolder
}

Register-ArgumentCompleter -CommandName docs, dl, desktop, pics, music, videos, home -ParameterName Subfolder -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $basePath = $null

    # Usamos un 'switch' para determinar la ruta base correcta
    # según el comando que se esté ejecutando (docs, dl, etc.).
    switch ($commandName) {
        'docs'    { $basePath = [Environment]::GetFolderPath('MyDocuments') }
        'desktop' { $basePath = [Environment]::GetFolderPath('Desktop') }
        'pics'    { $basePath = [Environment]::GetFolderPath('MyPictures') }
        'music'   { $basePath = [Environment]::GetFolderPath('MyMusic') }
        'videos'  { $basePath = [Environment]::GetFolderPath('MyVideos') }
        'home'    { $basePath = [Environment]::GetFolderPath('UserProfile') }
        'dl'      {
            # Para Downloads, replicamos la lógica confiable que usa el registro
            $regPath = 'hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
            $regKey = '{374DE290-123F-4565-9164-39C4925E467B}'
            $rawPath = (Get-ItemProperty -Path $regPath).$regKey
            $basePath = [System.Environment]::ExpandEnvironmentVariables($rawPath)
        }
    }

    # Si por alguna razón no se encontró la ruta base, no continuamos.
    if (-not (Test-Path $basePath)) { return }

    # El resto de la lógica es idéntica: busca directorios que coincidan.
    Get-ChildItem -Path $basePath -Directory | Where-Object {
        $_.Name -like "$wordToComplete*"
    } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

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
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Subfolder
    )

    $BasePath = $global:DevPhpPath

    # Validamos primero que la variable global exista
    if (-not $BasePath) {
        Write-Warning "La variable global `$global:DevPhpPath no está definida."
        return
    }

    $FullPath = Join-Path -Path $BasePath -ChildPath $Subfolder
    if (Test-Path $FullPath) {
        Set-Location $FullPath
        Write-Host "🐘 Navegando a '$FullPath'" -ForegroundColor Green
    } else {
        Write-Warning "La ruta no existe: '$FullPath'"
    }
}

# Función para ir a la carpeta de proyectos Python
function Enter-PyProjects {
    [CmdletBinding()] # La convertimos en una función avanzada
    param(
        # Añadimos un parámetro opcional y posicional para la subcarpeta del proyecto
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Subfolder
    )

    $BasePath = $global:DevPyPath

    # Es buena práctica validar que la variable global de la ruta base exista
    if (-not $BasePath) {
        Write-Warning "La variable global `$global:DevPyPath no está definida en tu perfil."
        return # Detiene la ejecución si la ruta base no existe
    }
    
    # Construimos la ruta final usando Join-Path, que es más seguro
    $targetPath = if (-not [string]::IsNullOrEmpty($Subfolder)) {
        Join-Path -Path $BasePath -ChildPath $Subfolder
    } else {
        $BasePath
    }

    # Validamos si la ruta final existe antes de intentar navegar
    if (Test-Path -Path $targetPath) {
        Set-Location -Path $targetPath
        Write-Host "🐍 Navegando a '$targetPath'" -ForegroundColor Green
    } else {
        Write-Warning "La ruta no existe: '$targetPath'"
    }
}

Register-ArgumentCompleter -CommandName Enter-PyProjects, Enter-PhpProjects -ParameterName Subfolder -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    # Determina la ruta base según la función que se esté usando (ppy o pphp)
    $basePath = if ($commandName -eq 'Enter-PyProjects') {
        $global:DevPyPath
    } else {
        $global:DevPhpPath
    }

    if (-not (Test-Path $basePath)) { return }

    # Busca directorios dentro de la ruta base que coincidan con lo que has escrito
    Get-ChildItem -Path $basePath -Directory | Where-Object {
        $_.Name -like "$wordToComplete*"
    } | ForEach-Object {
        # Devuelve el nombre del directorio como una sugerencia de autocompletado
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}