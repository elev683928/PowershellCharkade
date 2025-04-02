# Ensure PowerShell runs with execution policy bypassed
Set-ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

# Define the log file path
$logFile = "$env:USERPROFILE\Desktop\install_log.txt"

# Function to log messages to both console and log file
function Log-Message {
    param (
        [string]$message
    )
    Write-Output $message
    Add-Content -Path $logFile -Value ("$(Get-Date) - " + $message)
}

# Log the start of the installation process
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
    try {
        choco install steam -y
        Log-Message "Steam installation started."
    } catch {
        Log-Message "Failed to install Steam."
    }

    try {
        choco install epicgameslauncher -y
        Log-Message "Epic Games Launcher installation started."
    } catch {
        Log-Message "Failed to install Epic Games Launcher."
    }
}

# Function to install Marvel Rivals from Steam
function Install-MarvelRivals {
    $SteamAppID = "2767030"  # Marvel Rivals App ID
    $SteamPath = "$env:ProgramFiles(x86)\Steam"
    
    Log-Message "Checking if Steam is installed..."
    if (Test-Path "$SteamPath\steam.exe") {
        Log-Message "Steam found. Checking if it's up to date..."
        Start-Process -FilePath "$SteamPath\steam.exe" -ArgumentList "-silent" -NoNewWindow -Wait
        Log-Message "Steam is updated and ready."

        Log-Message "Installing Marvel Rivals from Steam..."
        Start-Process -FilePath "$SteamPath\steam.exe" -ArgumentList "steam://install/$SteamAppID" -NoNewWindow -Wait
        Log-Message "Marvel Rivals installation initiated."
    } else {
        Log-Message "Steam is not installed correctly or its path is incorrect."
        exit 1
    }
}

# Function to install Fortnite via Epic Games Launcher
function Install-Fortnite {
    $EpicGamesPath = "$env:ProgramFiles\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"

    Log-Message "Checking if Epic Games Launcher is installed..."
    if (Test-Path $EpicGamesPath) {
        Log-Message "Epic Games Launcher found. Checking if it's up to date..."
        Start-Process -FilePath $EpicGamesPath -ArgumentList "--no-detect" -NoNewWindow -Wait
        Log-Message "Epic Games Launcher is updated and ready."

        Log-Message "Installing Fortnite via Epic Games Launcher..."
        Start-Process -FilePath $EpicGamesPath -ArgumentList "launch --game=fortnite" -NoNewWindow -Wait
        Log-Message "Fortnite installation initiated."
    } else {
        Log-Message "Epic Games Launcher is not installed correctly or its path is incorrect."
        exit 1
    }
}

# Run the installation functions
Install-Chocolatey
Install-Apps

# Pause briefly to allow the launchers to update before starting game installations
Log-Message "Waiting for Steam and Epic Games Launcher to update..."
Start-Sleep -Seconds 60  # Adjust the time depending on your connection and how long updates typically take

Install-MarvelRivals
Install-Fortnite

# End of the process
Log-Message "Installation process completed."

# Delete the log file after installation is complete
if (Test-Path $logFile) {
    Remove-Item -Path $logFile -Force
    Log-Message "Log file deleted after successful installation."
}

