# 2. Archivo 02_theme.ps1 (Tema y Experiencia Visual)
# Todo lo que afecta a cómo se ve y se siente la terminal.

# --- CONFIGURACIÓN DE CODIFICACIÓN (IMPORTANTE PARA EMOJIS) ---
# Asegura que PowerShell maneje correctamente caracteres especiales como emojis
# al interactuar con programas externos a través de la tubería (|).
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Sistema Operativo y Hardware
$os = Get-CimInstance Win32_OperatingSystem
$memFree = [Math]::Truncate($os.FreePhysicalMemory / 1024)
$memTotal = [Math]::Truncate($os.TotalVisibleMemorySize / 1024)
$pcName = $os.CSName
$dateTime = Get-Date -Format "dd/MM/yyyy HH:mm"

# --- Red ---

# Función auxiliar para obtener la IP de un adaptador físico de forma segura.
function Get-PhysicalIpAddress {
    param (
        [int]$InterfaceType, # 6 para Ethernet, 71 para Wi-Fi
        [string]$DisconnectedMessage = "Desconectado",
        [string]$NoIpMessage = "Conectado"
    )

    # 1. Buscar el adaptador físico, del tipo correcto y con estado 'Up'.
    $adapter = Get-NetAdapter -Physical | Where-Object { $_.InterfaceType -eq $InterfaceType -and $_.Status -eq 'Up' } | Select-Object -First 1

    # 2. Si no se encuentra, está desconectado.
    if (-not $adapter) {
        return $DisconnectedMessage
    }

    # 3. Si se encuentra, intentar obtener su dirección IPv4.
    $ipAddress = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IPAddress -First 1

    # 4. Devolver la IP si existe, si no, el mensaje de 'Conectado' (sin IP visible).
    if ($ipAddress) {
        return $ipAddress
    }
    else {
        return $NoIpMessage
    }
}

# Usamos la nueva función para obtener las IPs de forma segura.
$ethIp = Get-PhysicalIpAddress -InterfaceType 6
$wifiIp = Get-PhysicalIpAddress -InterfaceType 71
# --- PRESENTACIÓN EN PANTALLA ---

# Línea 1: Usuario y Hostname
"$($red)$($icons.User)$reset @daom89 $($white)en$reset $($red)$($icons.PC)$reset $pcName"

# Línea 2: Sistema Operativo
"$($green)$($icons.Windows)$reset $($os.Caption) $($os.OSArchitecture)"

# Línea 3: Versión y Build
"  $($magenta)$($icons.Version)$reset Version $($yellow)$($os.Version)$reset $($magenta)$($icons.Build)$reset Build $($yellow)$($os.BuildNumber)$reset"

# Línea 4: Memoria y Fecha/Hora
"$($white)$($icons.Memory)$reset $memFree / $memTotal MiB $($white)|$reset $($white)$($icons.Clock)$reset $dateTime"

# Línea 5: Red
"$($white)$($icons.Ethernet)$reset $ethIp $($white)|$reset $($white)$($icons.Wifi)$reset $wifiIp $($white)"

# Salto de línea para separar del banner
Write-Host ""

# Banner Final
Write-Figlet "@daom89" -Font "small" -LayoutRule "Smushing" | Out-Rainbow -Animate -Speed 90
# --- Cargar Frase Aleatoria desde Archivo Local CSV ---
# Construye la ruta al archivo de frases de forma dinámica
$rutaArchivoFrases = Join-Path -Path (Split-Path $PROFILE) -ChildPath "Data\frases.csv"

# Importa todas las frases del CSV y elige una al azar
$frases = Import-Csv -Path $rutaArchivoFrases
$fraseAleatoria = Get-Random -InputObject $frases

# Formatea el texto para que incluya autor
$fortuneText = "'$($fraseAleatoria.Frase)' - $($fraseAleatoria.Autor)"
cowsay -r $fortuneText | lolcat

# --- INICIALIZACIÓN DE MÓDULOS DE TEMA ---
Import-Module PSReadLine
Import-Module -Name Terminal-Icons
Import-Module git-aliases -DisableNameChecking

# Configuración del prompt con Oh My Posh
oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression

# Configuración de PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView