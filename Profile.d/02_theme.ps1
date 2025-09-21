# 2. Archivo 02_theme.ps1 (Tema y Experiencia Visual)
# Todo lo que afecta a cómo se ve y se siente la terminal.

# Sistema Operativo y Hardware
$os = Get-CimInstance Win32_OperatingSystem
$memFree = [Math]::Truncate($os.FreePhysicalMemory / 1024)
$memTotal = [Math]::Truncate($os.TotalVisibleMemorySize / 1024)
$pcName = $os.CSName
$dateTime = Get-Date -Format "dd/MM/yyyy HH:mm"

# Red
$ethIp = Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
$wifiIp = Get-NetIPAddress -InterfaceAlias 'Wi-Fi' -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress

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
figlet "@daom89" | meow
$apiQuote = Invoke-RestMethod -Uri 'https://zenquotes.io/api/random'
# Formatea el texto para que incluya autor
$fortuneText = "'$($apiQuote.q)' - $($apiQuote.a)"
cowsay -r $fortuneText | meow

# --- INICIALIZACIÓN DE MÓDULOS DE TEMA ---
Import-Module PSReadLine
Import-Module -Name Terminal-Icons
Import-Module git-aliases -DisableNameChecking

# Configuración del prompt con Oh My Posh
oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression

# Configuración de PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView