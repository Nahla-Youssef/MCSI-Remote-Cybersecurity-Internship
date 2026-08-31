# Define service variables
$serviceName = "InsecureService"
$serviceDisplayName = "Insecure Windows Service"
$serviceDescription = "A vulnerable service with insecure permissions."
$servicePath = "C:\Windows\System32\dummymalware.exe"  # You can specify any executable
$serviceStartMode = "Automatic"

# Step 1: Create the service
New-Service -Name $serviceName -BinaryPathName $servicePath -DisplayName $serviceDisplayName -Description $serviceDescription -StartupType $serviceStartMode

# Step 2: Modify registry permissions to make it insecure
$acl = Get-Acl "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule("Everyone", "FullControl", "Allow")
$acl.SetAccessRule($rule)
Set-Acl "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName" $acl

Write-Host "$serviceName has been created with insecure permissions!"
