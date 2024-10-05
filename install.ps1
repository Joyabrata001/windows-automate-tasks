# Path to the file containing the list of applications
$appList = Get-Content "$home\Desktop\install_apps.txt"

# Log file to record installation statuses
$logFile = "$home\Desktop\winget_install_log.txt"

# Function to log messages to a file
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logFile "$timestamp - $message"
}

# Check if an app is already installed
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

# Iterate through each app and install it if not already installed
foreach ($app in $appList) {
    Write-Host "Processing $app..."

    # Check if the app is already installed
    if (Is-AppInstalled $app) {
        Write-Host "$app is already installed. Skipping..."
        Log-Message "$app is already installed. Skipping..."
    } else {
        Write-Host "Installing $app..."
        Log-Message "Installing $app..."

        # Try to install the application
        try {
            winget install --id $app --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$app installed successfully."
                Log-Message "$app installed successfully."
            } else {
                Write-Host "Failed to install $app."
                Log-Message "Failed to install $app."
            }
        } catch {
            Write-Host "Error installing ${app}: $_"
            Log-Message "Error installing ${app}: $_"
        }
    }
}