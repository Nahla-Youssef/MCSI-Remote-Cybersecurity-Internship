# Parameters
param (
    [Parameter(Mandatory=$true)]
    [string] $remoteMachine
)

# Variables
$sysmonExecutable = "C:\Sysmon\Sysmon64.exe"
$configFile = "C:\Sysmon\sysmon-config.xml"

# Step 1: Prompt for credentials
$credential = Get-Credential

# Step 2: Establish a remote session with Basic Authentication
Write-Host "-> Establishing session with $remoteMachine"
try {
    $remoteSession = New-PSSession -ComputerName $remoteMachine -Credential $credential -Authentication Basic -ErrorAction Stop
} catch {
    Write-Host "Failed to connect to $remoteMachine. Ensure the machine is reachable and PowerShell remoting is enabled."
    return
}

# Step 3: Copy Sysmon executable and configuration file to the remote machine
Write-Host "-> Copying Sysmon executable and configuration file to the remote machine's C:\Windows directory"
try {
    Copy-Item -Path $sysmonExecutable -Destination "C:\Windows" -Force -ToSession $remoteSession
    Copy-Item -Path $configFile -Destination "C:\Windows" -Force -ToSession $remoteSession
} catch {
    Write-Host "Failed to copy files to $remoteMachine. Check permissions and network access."
    Remove-PSSession -Session $remoteSession
    return
}

# Step 4: Install or reinstall Sysmon on the remote machine
Write-Host "-> Installing Sysmon on $remoteMachine"
$sysmonExeName = [System.IO.Path]::GetFileName($sysmonExecutable)
$configFileName = [System.IO.Path]::GetFileName($configFile)

try {
    Invoke-Command -Session $remoteSession -ScriptBlock {
        param($sysmonExe)
        if (Test-Path "C:\Windows\$sysmonExe") {
            Write-Host "Uninstalling existing Sysmon instance..."
            cmd.exe /C "C:\Windows\$sysmonExe -u force" | Out-Null
        }
    } -ArgumentList $sysmonExeName

    Invoke-Command -Session $remoteSession -ScriptBlock {
        param($sysmonExe, $configFile)
        Write-Host "Installing Sysmon with new configuration..."
        cmd.exe /C "C:\Windows\$sysmonExe -accepteula -i C:\Windows\$configFile" | Out-Null
    } -ArgumentList $sysmonExeName, $configFileName
    Write-Host "-> Sysmon installation complete on $remoteMachine"
} catch {
    Write-Host "Failed to install Sysmon on $remoteMachine. Please check permissions and system requirements."
}

# Step 5: Clean up
Remove-PSSession -Session $remoteSession
