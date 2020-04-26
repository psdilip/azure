# Initiate Variables
$resourceGroupName = "Sai-ResourceGroup4"
$location = "eastus"
$vmName = "SaiVM-IIS-VM"
$vmNetWorkName = "SaiVM-Network"
$subnetName = "SaiVM-Subnet"
$securityGroupName = "SaiVM-SecurityGroup"
$publicIpAddressName = "SaiVM-PublicAddress"

#Create user object
$cred = Get-Credential -Message "Enter a username and password for the machine"

#Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

#Create a virtual machine
New-AzVM `
    -ResourceGroupName $resourceGroupName `
    -Name $vmName `
    -Location $location `
    -ImageName "Win2019Datacenter" `
    -Size "Standard_D2s_v3" `
    -VirtualNetworkName $vmNetWorkName `
    -SubnetName $subnetName `
    -SecurityGroupName $securityGroupName `
    -PublicIpAddressName $publicIpAddressName `
    -Credential $cred `
    -OpenPorts 80

$PublicSettings = '{"commandtoExecute": "powershell Add-WindowsFeature Web-Server"}'

#Use Azure Extension to create a IIS WebServer
Set-AzVMExtension -ExtensionName "IIS" -ResourceGroupName $resourceGroupName -VMName $vmName  `
-Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion 1.4 `
-SettingString $PublicSettings -Location $location
