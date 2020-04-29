# Initiate Variables
$resourceGroupName = "Sai-ResourceGroup-$(Get-Random)"
$location = "eastus"
$vmName = "SaiVM-Nginx-VM"
$vmNetWorkName = "SaiVM-Network"
$subnetName = "SaiVM-Subnet"
$securityGroupName = "SaiVM-SecurityGroup"
$publicIpAddressName = "SaiVM-PublicAddress"

#Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

#Username and password
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

#Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
-Name $subnetName `
-AddressPrefix 192.168.1.0/24

#Create a virtual network
$vNet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location `
-Name $vmNetWorkName -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

#Create a public IP address
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location `
-Name $publicIpAddressName -AllocationMethod Static -IdleTimeoutInMinutes 4

#Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH -Protocol Tcp `
 -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
 -DestinationPortRange 22 -Access Allow

#Create an inbound network security group rule for port 80
$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleHTTP -Protocol Tcp `
-Direction Inbound -Priority 2000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 80 -Access Allow

#Create an inbound network security group rule for port 22
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location `
 -Name $securityGroupName -SecurityRules $nsgRuleSSH,$nsgRuleHTTP

 #Create a virtual network card and associate with public IP address and NSG
 $nic = New-AzNetworkInterface -Name myNic -ResourceGroupName $resourceGroupName -Location $location `
 -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

 #Create a virtual machine configuration
 $vmConfig = New-AzVMConfig -VMName $vmName -VMSize Standard_D2s_v3 | `
 Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred -DisablePasswordAuthentication | `
 Set-AzVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 14.04.2-LTS -Version latest | `
 Add-AzVMNetworkInterface -Id $nic.Id

 #Configure SSH Keys
 $sshPublicKey = Get-Content ".ssh\id_rsa.pub"
 Add-AzVMSshPublicKey -VM $vmConfig -KeyData $sshPublicKey -Path "/home/azureuser/.ssh/authorized_keys"

 #Create a virtual machine
 New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

 #Install NGINX
 $PublicSettings = '{"commandToExecute":"apt-get -y update && apt-get -y install nginx"}'

 Set-AzVMExtension -ExtensionName "NGINX" -ResourceGroupname $resourceGroupName -VMName $vmName `
 -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
 -SettingString $PublicSettings -Location $location