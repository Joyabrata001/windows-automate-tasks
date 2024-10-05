# Retrieve environment variables
$pathVars = Get-ChildItem Env:Path

# Split the Path variable by ';' and display each path on a new line
$pathArray = $pathVars.Value -split ';'
foreach ($path in $pathArray) {
    Write-Output $path
}