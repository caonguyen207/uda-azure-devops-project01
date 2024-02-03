packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1"
    }
  }
}

variable "client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "client_secret" {
  type    = string
  default = "${env("ARM_CLIENT_SECRET")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
}

variable "resource_group_name" {
  type    = string
  default = "Azuredevops"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_size" {
  type    = string
  default = "Standard_DS1_v2"
}

source "azure-arm" "my-image" {
  azure_tags = {
    name = "Ubuntu image ${var.vm_size} created by Packer"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "18.04-LTS"
  location                          = "${var.location}"
  managed_image_name                = "myfirstimage"
  managed_image_resource_group_name = "Azuredevops"
  os_type                           = "Linux"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  vm_size                           = "${var.vm_size}"
}

build {
  sources = ["source.azure-arm.my-image"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["apt-get update", "apt-get upgrade -y", "apt-get -y install nginx", "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync", "echo 'Hello, World!' > index.html", "nohup busybox httpd -f -p 80 &"]
    inline_shebang  = "/bin/sh -x"
  }

}
