#----------Ask for Username---------------
$userName = Read-Host 'What is your name? '
Write-Host "Welcome, $userName. This is Jarvis, your assistant. I will help you create an IIS Webserver using Azure today. I will ask you several questions regarding your preference"

#----------Initiate Variables-------------
$resourceGroupName = "$userName-ResourceGroup-$(Get-Random)"
$vmName = "$userName-IIS-VM"
$vmNetWorkName = "$userName-VM-Network"
$subnetName = "$userName-Subnet"
$securityGroupName = "$userName-SecurityGroup"
$publicIpAddressName = "$userName-PublicAddress"

#-----------Subscription-------------------
#Get subscriptions
$availableSubscription = Get-AzureRmSubscription
#List subscriptions
$availableSubscription | Format-Table | Out-String | Write-Host
#Ask user subscription
$userSubscription = Read-Host 'Copy your subscription id here: '
#Selects subscription
Select-AzureRmSubscription -SubscriptionId $userSubscription

#-----------Location------------------------
#Get Locations
$getLocations = Get-AzureRmLocation | Format-Table Location
#List Locations
$getLocations | Format-Table | Out-String | Write-Host
#Ask user Location
$userLocation = Read-Host 'Which location do you want to use?: '
#Acknowledges subscription
Write-Host "Using $userLocation"

#-----------Resource Group-------------------
#Get Resource Groups
$getResourceGroups = Get-AzureRmResourceGroup | Where-Object {$_.Location -eq $userLocation} | Format-Table
#List Resource Groups
$getResourceGroups | Format-Table | Out-String | Write-Host
#Check if resource group exists
If ($getResourceGroups) {
    #Acknowledges that you have resource groups available
    Write-Host "Looks like you already have a Resource group in this location."
    #Ask user if they want to use the existing resource or create a new resource
    $userResourceGroup = Read-Host 'Copy your resource group name here or type "NEW" to create a new resource: '
    #If they type New, a new resource gets created automatically
	If ($userResourceGroup -eq "New") {
        New-AzResourceGroup -Name $resourceGroupName -Location $userLocation
        Write-Host "Created a new resource group"
      
        }  Else {
        #If not they use the existing resource group to create the VM
        $resourceGroupName = $userResourceGroup
        Write-Host "Using resource group $resourceGroupName"
      
      } 
} Else {
    #If a resource group doesnt exist then it automatically creates a new one
    Write-Warning -Message "You dont have existing resource groups in this location. Creating a new one"
    New-AzResourceGroup -Name $resourceGroupName -Location $userLocation
    Write-Host "Created a new resource group"
}

#------------Image------------------------------
<#
Steps to find an image in a location:
1. Pick a publisher
2. Pick an offer
3. Pick a sku
#>

#----Publisher---
#Get publishers that has Micosoft in the name, since we are creating an IIS Server
$getPublisher = Get-AzVMImagePublisher -Location $userLocation | Select-Object PublisherName| Where-Object {$_.PublisherName -like '*Microsoft*'}
#List Publisher
$getPublisher | Format-Table | Out-String | Write-Host
#Ask user publisher
$userPublisher = Read-Host 'Pick a publisher ("MicrosoftWindowsServer" Preffered): '

#----Offer-----
#Get offer
$getOffer = Get-AzVMImageOffer -Location $userLocation -PublisherName $userPublisher | Select-Object Offer
#List offer
$getOffer | Format-Table | Out-String | Write-Host
#Ask user offer
$userOffer = Read-Host 'Pick an offer ("WindowsServer" Preffered): '

#----Sku------
#Get Sku
$getSku = Get-AzVMImageSku -Location $userLocation -PublisherName $userPublisher -Offer $userOffer | Select-Object Skus
#List Sku
$getSku | Format-Table | Out-String | Write-Host
#Ask user Sku
$userSku = Read-Host 'Pick a sku ("2019-Datancenter" Preffered): '

#----Image-----
#Get image
$getImage = Get-AzVMImage -Location $userLocation -PublisherName $userPublisher -Offer $userOffer -Sku $userSku
#List Image
$getImage | Format-Table | Out-String | Write-Host
#Ask user image
$userImage = Read-Host 'To pick your image write in this format ("publisher:offer:sku:version") this will create the URN: '
#Acknowledge
Write-Host "You are using $userImage"



#------------VM Size---------------------------
#Get available sizes based on location
$getSize = Get-AzureRmVMSize -Location $userLocation
#List sizes
$getSize | Format-Table | Out-String | Write-Host
#Ask user for VM size
$userVMSize = Read-Host 'Pick a size (Standard_D2s_v3 is Preffered or Similar): '
#Acknowledge
Write-Host "You are using $userVMSize"

#------------Credentials------------------------
#Ask user for username and password
$cred = Get-Credential -Message "Enter a username and password for the machine"

#------------Create Virtual Machine-------------
#Create a virtual machine
New-AzVM `
    -ResourceGroupName $resourceGroupName `
    -Name $vmName `
    -Location $userLocation `
    -ImageName $userImage `
    -Size $userVMSize `
    -VirtualNetworkName $vmNetWorkName `
    -SubnetName $subnetName `
    -SecurityGroupName $securityGroupName `
    -PublicIpAddressName $publicIpAddressName `
    -Credential $cred `
    -OpenPorts 80

#-------------Install IIS Server----------------
$PublicSettings = '{"commandtoExecute": "powershell Add-WindowsFeature Web-Server"}'

#Use Azure Extension to create a IIS WebServer
Set-AzVMExtension -ExtensionName "IIS" -ResourceGroupName $resourceGroupName -VMName $vmName  `
-Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion 1.4 `
-SettingString $PublicSettings -Location $userlocation


Write-Host "Get the public ip and type it in your browser"