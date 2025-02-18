# Check if Node.js is installed
if (Get-Command node -ErrorAction SilentlyContinue) {
    node -v
} else {
    Write-Output "Node.js is not installed"
}

# Check if npm is installed
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm -v
} else {
    Write-Output "npm is not installed"
}

# Check if Docker is installed
if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker --version
} else {
    Write-Output "Docker is not installed"
}

# Check if df command is available
if (Get-Command df -ErrorAction SilentlyContinue) {
    df -h
} else {
    Write-Output "Command not available"
}