# Contenido del archivo: colors.ps1

# --- Paleta de Colores ANSI ---
$esc = "$([char]27)" # Define el carácter de escape

# Estilos de texto
$reset = "${esc}[0m"  # Restablece todos los estilos y colores
$bold = "${esc}[1m"
$underline = "${esc}[4m"

# Colores de texto (foreground)
$black = "${esc}[30m"
$red = "${esc}[31m"
$green = "${esc}[32m"
$yellow = "${esc}[33m"
$blue = "${esc}[34m"
$magenta = "${esc}[35m"
$cyan = "${esc}[36m"
$white = "${esc}[37m"

# --- Iconos Nerd Font ---
$icons = @{
    User     = "🧑🏻" #  nf-fa-user_circle_o
    PC       = "🖥️" #  nf-fa-desktop
    Windows  = "🪟" #  nf-dev-windows
    Memory   = "⚙️" #  nf-fa-microchip
    Clock    = "🕙" #  nf-fa-clock_o
    Calendar = "📅" #  nf-fa-calendar
    Ethernet = "🔌" #  nf-fa-plug
    Wifi     = "🛜" #  nf-fa-wifi
    PublicIP = "🌍" #  nf-cod-globe
    Build    = "📦" #  nf-fa-building_o
    Version  = "🔖" #  nf-fa-tag
}