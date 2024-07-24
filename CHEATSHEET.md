```powershell
Get-AzVM -Name "<vm-name>" -ResourceGroupName "<resource-group>" -Status 
```

# Install tooling

```powershell
winget install Microsoft.Azure.FunctionsCoreTools
# Restart win terminal
``` 

# Create Functions App

```powershell
cd source
# create func app
func init "<func-app-name>" --powershell

# create func
func new --name Check-VmStatus --template "Timer Trigger"  --authlevel "anonymous"

# start func app
Func start
```

# Deploy via CLI

```powershell
func azure functionapp publish "<func-app-name>"
```

# Deploy via TF

```powershell
terraform apply -var "RESOURCE_GROUP=<resource-group>" -var "VM_NAME=<vm-name>"
```