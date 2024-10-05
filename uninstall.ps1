# Path to the file containing the list of applications to uninstall
$appList = Get-Content "$home\Desktop\uninstall_apps.txt"

# Log file to record uninstallation statuses
$logFile = "$home\Desktop\winget_uninstall_log.txt"

# Function to log messages to a file
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logFile "$timestamp - $message"
}

# Check if an app is installed
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

# Iterate through each app and uninstall it if installed
foreach ($app in $appList) {
    Write-Host "Processing $app for uninstallation..."

    # Check if the app is installed
    if (Is-AppInstalled $app) {
        Write-Host "Uninstalling $app..."
        Log-Message "Uninstalling $app..."

        # Try to uninstall the application
        try {
            winget uninstall --id $app --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$app uninstalled successfully."
                Log-Message "$app uninstalled successfully."
            } else {
                Write-Host "Failed to uninstall $app."
                Log-Message "Failed to uninstall $app."
            }
        } catch {
            Write-Host "Error uninstalling ${app}: $_"
            Log-Message "Error uninstalling ${app}: $_"
        }
    } else {
        Write-Host "$app is not installed. Skipping..."
        Log-Message "$app is not installed. Skipping..."
    }
}