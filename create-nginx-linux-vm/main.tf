# Configure the Microsoft Azure Provider
provider "azurerm" {
  version = "~>2.0"
  features {}
}
#Create a resource group
resource "azurerm_resource_group" "sai-linux-vm-resource-group" {
  name     = "sai-linux-vm-resource-group"
  location = "eastus"

  tags = {
    environment = "Sai Linux VM Demo"
  }
}
#Create virtual network
resource "azurerm_virtual_network" "sai-linux-vm-virtual-network" {
  name                = "sai-linux-vm-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.sai-linux-vm-resource-group.name

  tags = {
    environment = "Sai Linux VM Demo"
  }
}
#Create a subnet
resource "azurerm_subnet" "sai-linux-vm-subnet" {
  name                 = "sai-linux-vm-subnet"
  resource_group_name  = azurerm_resource_group.sai-linux-vm-resource-group.name
  virtual_network_name = azurerm_virtual_network.sai-linux-vm-virtual-network.name
  address_prefix       = "10.0.2.0/24"
}
#Create a public ip address
resource "azurerm_public_ip" "sai-linux-vm-public-ip" {
  name                = "sai-linux-vm-public-ip"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.sai-linux-vm-resource-group.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Sai Linux VM Demo"
  }
}
#Create a security group
resource "azurerm_network_security_group" "sai-linux-vm-security-group" {
  name                = "sai-linux-vm-security-group"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.sai-linux-vm-resource-group.name

  tags = {
    environment = "Sai Linux VM Demo"
  }
}
# Create a security rule for ssh
resource "azurerm_network_security_rule" "sai-linux-vm-ssh-access" {
  name                        = "sai-linux-vm-ssh-access-rule"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sai-linux-vm-resource-group.name
  network_security_group_name = azurerm_network_security_group.sai-linux-vm-security-group.name
}
# Create a security rule for http
resource "azurerm_network_security_rule" "sai-linux-vm-http-access" {
  name                        = "sai-linux-vm-http-access-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sai-linux-vm-resource-group.name
  network_security_group_name = azurerm_network_security_group.sai-linux-vm-security-group.name
}

#Create a network interface card
resource "azurerm_network_interface" "sai-linux-vm-nic" {
  name                = "sai-linux-vm-nic"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.sai-linux-vm-resource-group.name

  ip_configuration {
    name                          = "sai-linux-vm-nic-Configuration"
    subnet_id                     = azurerm_subnet.sai-linux-vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sai-linux-vm-public-ip.id
  }

  tags = {
    environment = "Sai Linux VM Demo"
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "sai-linux-vm-security-group-association" {
  network_interface_id      = azurerm_network_interface.sai-linux-vm-nic.id
  network_security_group_id = azurerm_network_security_group.sai-linux-vm-security-group.id
}

# Generate a random number
resource "random_id" "sai-linux-vm-random-number-generator" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.sai-linux-vm-resource-group.name
  }

  byte_length = 8
}
#Create a storage account
resource "azurerm_storage_account" "sai-linux-vm-storage-account" {
  name                     = "diag${random_id.sai-linux-vm-random-number-generator.hex}"
  resource_group_name      = azurerm_resource_group.sai-linux-vm-resource-group.name
  location                 = "eastus"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    environment = "Sai Linux VM Demo"
  }
}
#Create a virtual machine
resource "azurerm_linux_virtual_machine" "sai-linux-vm" {
  name                  = "sai-linux-vm"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.sai-linux-vm-resource-group.name
  network_interface_ids = [azurerm_network_interface.sai-linux-vm-nic.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    name                 = "sai-linux-vm-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  computer_name                   = "sai-linux-vm-computer"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/Users/sponnaganti/.ssh/azure.pub")
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sai-linux-vm-storage-account.primary_blob_endpoint
  }

  tags = {
    environment = "Sai Linux VM Demo"
  }
}
#Run a custom script to install nginx
resource "azurerm_virtual_machine_extension" "sai-linx-vm-extension" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.sai-linux-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${filebase64("install_nginx.sh")}"
    }
SETTINGS

  tags = {
    environment = "Sai Linux VM Demo"
  }
}