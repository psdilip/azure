# Create a Azure Linux VM with Ngnix via Terraform

The terraform script creates a Linux VM with pre-installed nginx

## Getting Started

1. Clone the repo
2. Replace the public key file path with yours
3. Replace "sai" with your name
4. Run the following:
```
terraform init
terraform plan
terraform apply
```

### Prerequisites

```
Install Terraform
Install Azure CLI
Azure Account + Subscription
SSH Public Key
```

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
