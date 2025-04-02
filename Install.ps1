# Ensure PowerShell runs with execution policy bypassed
Set-ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

# Function to log messages directly to the terminal
function Log-Message {
    param (
        [string]$message
    )
    Write-Host "[INFO] $message"
}

Log-Message "Starting installation process..."

# Function to install Chocolatey
function Install-Chocolatey {
    Log-Message "Checking if Chocolatey is installed..."
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Log-Message "Chocolatey not found. Installing Chocolatey..."
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

    # Install Steam using Chocolatey
    try {
        choco install steam -y | Write-Host
        Log-Message "Steam installation started."
    } catch {
        Log-Message "Failed to install Steam."
    }
    
    # Install Epic Games Launcher using Chocolatey
    try {
        choco install epicgameslauncher -y | Write-Host
        Log-Message "Epic Games Launcher installation started."
    } catch {
        Log-Message "Failed to install Epic Games Launcher."
    }
}

# Function to install Marvel Rivals from Steam
function Install-MarvelRivals {
    $SteamAppID = "2767030"  # Marvel Rivals App ID
    $SteamExe = "${env:ProgramFiles(x86)}\Steam\steam.exe"
    
    Log-Message "Checking if Steam is installed at $SteamExe..."
    if (Test-Path $SteamExe) {
        Log-Message "Steam found. Launching Steam to trigger update..."
        Start-Process -FilePath $SteamExe -ArgumentList "-silent" -NoNewWindow
        Log-Message "Steam launched to begin update."

        # Wait to ensure Steam is fully launched
        Start-Sleep -Seconds 10

        Log-Message "Installing Marvel Rivals from Steam..."
        Start-Process -FilePath $SteamExe -ArgumentList "steam://install/$SteamAppID" -NoNewWindow -Wait
        Log-Message "Marvel Rivals installation initiated."
    } else {
        Log-Message "Steam is not installed correctly or its path is incorrect: $SteamExe"
        exit 1
    }
}

# Function to install Fortnite via Epic Games Launcher
function Install-Fortnite {
    $EpicGamesPath = "${env:ProgramFiles}\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"
    
    Log-Message "Checking if Epic Games Launcher is installed at $EpicGamesPath..."
    if (Test-Path $EpicGamesPath) {
        Log-Message "Epic Games Launcher found. Launching Epic Games Launcher to trigger update..."
        Start-Process -FilePath $EpicGamesPath -ArgumentList "--no-detect" -NoNewWindow
        Log-Message "Epic Games Launcher launched to begin update."

        # Wait to ensure Epic Games Launcher is fully launched
        Start-Sleep -Seconds 10

        Log-Message "Installing Fortnite via Epic Games Launcher..."
        Start-Process -FilePath $EpicGamesPath -ArgumentList "launch --game=fortnite" -NoNewWindow -Wait
        Log-Message "Fortnite installation initiated."
    } else {
        Log-Message "Epic Games Launcher is not installed correctly or its path is incorrect: $EpicGamesPath"
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

# Launch Steam if it exists
if (Test-Path $SteamExePath) {
    Log-Message "Starting Steam..."
    Start-Process -FilePath $SteamExePath -NoNewWindow
} else {
    Log-Message "Steam not found at $SteamExePath."
}

# Launch Epic Games Launcher if it exists
if (Test-Path $EpicGamesExePath) {
    Log-Message "Starting Epic Games Launcher..."
    Start-Process -FilePath $EpicGamesExePath -NoNewWindow
} else {
    Log-Message "Epic Games Launcher not found at $EpicGamesExePath."
}

# Give them time to start before proceeding with game installs
Start-Sleep -Seconds 10  # Adjust the wait time as needed based on how long it takes for the launchers to start

Install-MarvelRivals
Install-Fortnite

Log-Message "Installation process completed."
