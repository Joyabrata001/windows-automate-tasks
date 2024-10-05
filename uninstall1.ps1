# Allow user to specify the path of the application list file and log file
$appListPath = Read-Host "Enter the path for the app list file (default: $HOME\Desktop\uninstall_apps.txt)"
if (-not $appListPath) { $appListPath = "$HOME\Desktop\uninstall_apps.txt" }

$logFile = Read-Host "Enter the path for the log file (default: $HOME\Desktop\winget_uninstall_log.txt)"
if (-not $logFile) { $logFile = "$HOME\Desktop\winget_uninstall_log.txt" }

# Read the application list from the file
$appList = Get-Content $appListPath

# Function to log messages to a file
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logFile "$timestamp - $message"
}

# Function to check if an app is installed
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

# Function to uninstall an application
function Uninstall-App {
    param (
        [string]$app
    )
    try {
        winget uninstall --id $app --silent
        return $LASTEXITCODE -eq 0
    } catch {
        Log-Message "Error uninstalling ${app}: $_"
        return $false
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
    Write-Progress -Activity "Uninstalling applications..." -Status "$currentIndex of $totalApps" -PercentComplete (($currentIndex / $totalApps) * 100)

    # Check if the app is installed
    if (-not (Is-AppInstalled $app)) {
        Write-Host "$app is not installed. Skipping..."
        Log-Message "$app is not installed. Skipping..."
        $skippedList += $app
    } else {
        Write-Host "Uninstalling $app..."
        Log-Message "Uninstalling $app..."

        # Uninstall the app
        if (Uninstall-App $app) {
            Write-Host "$app uninstalled successfully."
            Log-Message "$app uninstalled successfully."
            $successList += $app
        } else {
            Write-Host "Failed to uninstall $app."
            Log-Message "Failed to uninstall $app."
            $failedList += $app
        }
    }
}

# Summary
Write-Host "`nUninstallation Summary:"
Write-Host "Successful uninstalls: $($successList.Count)"
Write-Host "Failed uninstalls: $($failedList.Count)"
Write-Host "Skipped uninstalls: $($skippedList.Count)"
Log-Message "Uninstallation Summary: $($successList.Count) successful, $($failedList.Count) failed, $($skippedList.Count) skipped."
