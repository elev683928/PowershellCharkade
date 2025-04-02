# Ensure PowerShell runs with execution policy bypassed
Set-ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

# Function to install Chocolatey
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Installing Chocolatey..."
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Output "Chocolatey is already installed."
    }
}

# Function to install applications via Chocolatey
function Install-Apps {
    Write-Output "Installing Steam and Epic Games Launcher..."
    choco install steam -y
    choco install epicgameslauncher -y
}

# Function to install Marvel Rivals (if Steam allows direct install via Steam URL)
function Install-MarvelRivals {
    $SteamAppID = "PLACEHOLDER"  # Replace with actual App ID when available
    $SteamPath = "$env:ProgramFiles(x86)\Steam"
    
    if (Test-Path "$SteamPath\steam.exe") {
        Write-Output "Installing Marvel Rivals from Steam..."
        Start-Process -FilePath "$SteamPath\steam.exe" -ArgumentList "steam://install/$SteamAppID" -NoNewWindow -Wait
    } else {
        Write-Output "Steam is not installed correctly or its path is incorrect."
    }
}

# Run functions
Install-Chocolatey
Install-Apps

# Pause briefly to allow installations to complete before attempting Marvel Rivals install
Start-Sleep -Seconds 30
Install-MarvelRivals
