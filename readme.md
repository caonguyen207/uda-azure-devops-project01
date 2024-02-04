# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Getting Started
1. Access to Azure Udacity lab and copy service principal / account information.
2. Open `https://portal.azure.com` and login to portal use credentials in step 1.
3. . Open GitBash and login to Azure environment by running `az login --use-device-code`. Copy the URL / authen code and paste to the brower in step 2.
4. Export below environment variables by using service principal credentials in step 1.
```
export ARM_CLIENT_ID="<APPID_VALUE>"
export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<TENANT_VALUE>"
```
5. Use AZ CLI to for policy definition
`az policy definition create --name "tagging-policy" --display-name "tagging-policy" --description "Do not allow create new resources if missing tags" --subscription "<sub-id>" --rules <path-to>/policy/tagging-policy.rules.json --mode Indexed --params <path-to>/policy/tagging-policy.params.json --metadata "version=1.0.0"` 
6. Clone this repository at [Repo](https://github.com/caonguyen207/uda-azure-devops-project01.git)
7. Navigate to folder contains packer template.
6. Run `packer init .` and then `packer build .`
7. Wait until command completed then double check by AZ CLI command: `az image list`
8. Create an SSH key pair `ssh-keygen -m PEM -t rsa -b 4096`
8. Navigate to `terraform` folder
9. Open `vars.tf` file and change the information as your request such as: VM SKU or number of VM instances in default backend pool...
10. Run `terraform init`
11. Run `terraform plan -out solution.plan`
12. Perform `terraform apply --auto-approve` if there is no error.
13. Verify all services by Azure portal.

### Output
1. SSH to testing  Public IP address and copy the IP.
2. Open browser and paste `http://<IP>`
    
#### Reference links:
1. [AZURERM DOCUMENTATION](https://registry.terraform.io/providers/hashicorp/azurerm)
2. [Security Group Definition](https://www.turingtaco.com/configuring-nsgs-in-azure-a-crucial-step-for-udacitys-deploying-a-web-server-project/)