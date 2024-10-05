# Installation Script

# Allow user to specify the path of the application list file and log file
$appListPath = Read-Host "Enter the path for the app list file (default: $HOME\Desktop\install_apps.txt)"
if (-not $appListPath) { $appListPath = "$HOME\Desktop\install_apps.txt" }

$logFile = Read-Host "Enter the path for the log file (default: $HOME\Desktop\winget_install_log.txt)"
if (-not $logFile) { $logFile = "$HOME\Desktop\winget_install_log.txt" }

# Read the application list from the file
$appList = Get-Content $appListPath

# Function to log messages to a file
function Log-Message {
    param (
        [string]$level,
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logFile "$timestamp [$level] - $message"
}

# Function to check if an app is already installed
function Is-AppInstalled {
    param (
        [string]$app
    )
    $installedApp = winget list --id $app 2>&1
    if ($installedApp -match "No installed package found") {
        return $false
    } else {
        return $true
    }
}

# Function to install an application
function Install-App {
    param (
        [string]$app,
        [int]$maxRetries = 3
    )
    $retryCount = 0
    while ($retryCount -lt $maxRetries) {
        try {
            winget install --id $app --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
        } catch {
            $retryCount++
            if ($retryCount -eq $maxRetries) {
                Log-Message "ERROR" "Failed to install $app after $maxRetries retries."
                return $false
            }
        }
    }
}

# Initialize lists for tracking results
$successList = @()
$failedList = @()
$skippedList = @()

# Main loop for processing the applications
$totalApps = $appList.Count
$currentIndex = 0

foreach ($app in $appList) {
    $currentIndex++
    Write-Progress -Activity "Installing applications..." -Status "$currentIndex of $totalApps" -PercentComplete (($currentIndex / $totalApps) * 100)

    # Check if the app is already installed
    if (Is-AppInstalled $app) {
        Write-Host "$app is already installed. Skipping..."
        Log-Message "INFO" "$app is already installed. Skipping..."
        $skippedList += $app
    } else {
        Write-Host "Installing $app..."
        Log-Message "INFO" "Installing $app..."

        # Install the app
        if (Install-App $app) {
            Write-Host "$app installed successfully."
            Log-Message "INFO" "$app installed successfully."
            $successList += $app
        } else {
            Write-Host "Failed to install $app."
            Log-Message "ERROR" "Failed to install $app."
            $failedList += $app
        }
    }
}

# Summary
Write-Host "`nInstallation Summary:"
Write-Host "Successful installs: $($successList.Count)"
Write-Host "Failed installs: $($failedList.Count)"
Write-Host "Skipped installs: $($skippedList.Count)"
Log-Message "INFO" "Installation Summary: $($successList.Count) successful, $($failedList.Count) failed, $($skippedList.Count) skipped."
