# Create a Azure Linux VM with Ngnix via Terraform

The terraform script creates a Linux VM with pre-installed nginx

## Getting Started

1. Clone the repo
2. cd into create-nginx-linux-vm
3. Replace the public key file path with yours in main.tf
4. Replace "sai" with your name in main.tf
5. Run the following in the same directory:
```
terraform init
terraform plan
terraform apply
```

### Prerequisites


* Install Azure CLI [Windows](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest) |[MacOs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest)
* Install Terraform [Windows/MacOS](https://www.terraform.io/downloads.html)
* [Setup Terraform Access to Azure](https://docs.microsoft.com/en-us/azure/terraform/terraform-install-configure)
* [SSH Public Key](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
* Azure Account and Subscription


### Terraform Resources Created

```
* Resource Group
* Virtual Network
* Subnet
* Public IP
* Security Group
* Security rule for SSH & HTTP
* NIC
* Random Number for Storage Account
* Storage Account
* Virtual Machine
* Virtual Machine Extension
```

## Authors

* *Sai Dilip Ponnaganti*

## Acknowledgments

* Terraform and Azure Documentation

## Helpful Links

* [Terraform Resources](https://www.terraform.io/docs/providers/azurerm/index.html#)
