# Ensure PowerShell runs with execution policy bypassed
Set-ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

# Log function with file output
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[INFO] $timestamp $message"
    
    Write-Host $logEntry
    Add-Content -Path "C:\Users\vboxuser\Desktop\install_log.txt" -Value $logEntry
}

Log-Message "Starting installation process..."

# Function to install Chocolatey
function Install-Chocolatey {
    Log-Message "Checking if Chocolatey is installed..."
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Log-Message "Chocolatey not found. Installing..."
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        try {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Log-Message "Chocolatey installed successfully."
        } catch {
            Log-Message "Failed to install Chocolatey. Exiting."
            exit 1
        }
    } else {
        Log-Message "Chocolatey is already installed."
    }
}

# Function to install Steam and Epic Games Launcher
function Install-Apps {
    Log-Message "Installing Steam and Epic Games Launcher..."

    try {
        choco install steam -y | Out-File -Append "C:\Users\vboxuser\Desktop\install_log.txt"
        Log-Message "Steam installation started."
    } catch {
        Log-Message "Failed to install Steam."
    }

    try {
        choco install epicgameslauncher -y | Out-File -Append "C:\Users\vboxuser\Desktop\install_log.txt"
        Log-Message "Epic Games Launcher installation started."
    } catch {
        Log-Message "Failed to install Epic Games Launcher."
    }
}

# Function to install Marvel Rivals from Steam
function Install-MarvelRivals {
    $SteamAppID = "2767030"  
    $SteamExe = "${env:ProgramFiles(x86)}\Steam\steam.exe"
    
    if (Test-Path $SteamExe) {
        Log-Message "Steam found. Launching Steam for updates..."
        Start-Process -FilePath $SteamExe -ArgumentList "-silent" -NoNewWindow
        Start-Sleep -Seconds 30  # Wait for Steam to update
        Log-Message "Installing Marvel Rivals from Steam..."
        Start-Process -FilePath $SteamExe -ArgumentList "steam://install/$SteamAppID" -NoNewWindow
        Log-Message "Marvel Rivals installation initiated."
    } else {
        Log-Message "Steam is not installed correctly or its path is incorrect."
        exit 1
    }
}

# Function to install Fortnite via Epic Games Launcher
function Install-Fortnite {
    $EpicGamesPath = "${env:ProgramFiles}\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"
    
    if (Test-Path $EpicGamesPath) {
        Log-Message "Epic Games Launcher found. Launching for updates..."
        Start-Process -FilePath $EpicGamesPath -ArgumentList "--no-detect" -NoNewWindow
        Start-Sleep -Seconds 20  # Wait for Epic Games Launcher to update
        Log-Message "Installing Fortnite via Epic Games Launcher..."
        Start-Process -FilePath $EpicGamesPath -ArgumentList "launch --game=fortnite" -NoNewWindow
        Log-Message "Fortnite installation initiated."
    } else {
        Log-Message "Epic Games Launcher is not installed correctly or its path is incorrect."
        exit 1
    }
}

# Run the installation functions
Install-Chocolatey
Install-Apps

# Launch Steam and Epic Games Launcher immediately after installation
Log-Message "Launching Steam and Epic Games Launcher to trigger updates..."
$SteamExePath = "${env:ProgramFiles(x86)}\Steam\steam.exe"
$EpicGamesExePath = "${env:ProgramFiles}\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"

# Start Steam if installed
if (Test-Path $SteamExePath) {
    Log-Message "Starting Steam..."
    Start-Process -FilePath $SteamExePath -NoNewWindow
    Start-Sleep -Seconds 20  # Ensure Steam has time to start updating
} else {
    Log-Message "Steam not found!"
}

# Start Epic Games Launcher if installed
if (Test-Path $EpicGamesExePath) {
    Log-Message "Starting Epic Games Launcher..."
    Start-Process -FilePath $EpicGamesExePath -NoNewWindow
    Start-Sleep -Seconds 20  # Ensure Epic Games Launcher has time to start updating
} else {
    Log-Message "Epic Games Launcher not found!"
}

# Install games
Install-MarvelRivals
Install-Fortnite

Log-Message "Installation process completed."
