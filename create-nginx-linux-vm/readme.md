# Create a Azure Linux VM with Ngnix via Terraform

The terraform script creates a Linux VM with pre-installed nginx

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.
- Clone the repo
- Replace the public key file path with yours
- Replace "sai" with your name
- Run the following:
```
terraform init
terraform plan
terraform apply
```

### Prerequisites

```
- Install Terraform
- Install Azure CLI
- Azure Account + Subscription
- SSH Public Key
```

### Terraform Resources Created

```
- Resource Group
- Virtual Network
- Subnet
- Public IP
- Security Group
- Security rule for SSH & HTTP
- NIC
- Random Number for Storage Account
- Storage Account
- Virtual Machine
- Virtual Machine Extension
```

## Authors

* **Sai Dilip Ponnaganti*

## Acknowledgments

* Terraform and Azure Documentation
