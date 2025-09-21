Import-Module PSReadLine
Import-Module -Name Terminal-Icons

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
# https://github.com/gluons/powershell-git-aliases?tab=readme-ov-file
Import-Module git-aliases -DisableNameChecking
oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression

Import-Module -Name Microsoft.WinGet.CommandNotFound

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

Set-PSReadLineOption -PredictionViewStyle ListView