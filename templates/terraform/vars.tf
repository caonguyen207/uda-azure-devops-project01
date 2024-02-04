variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  
  default     = "Azuredevops"
  description = "Default resource group name."
}

variable "no_of_vm" {
  description = "No of VMs."
  default     = 1
}

variable "vm_size" {
  default     = "Standard_DS1_v2"
  description = "VM SKU"
}

variable "vm_image_name" {
  default     = "myfirstimage" # Must be same with the name created by Packer.
  description = "The name of VM image."
}

variable "admin_username" {
  default     = "appadmin"
  description = "User use to login to VM"
}

variable "admin_password" {
  default     = "12345678x@X"
  description = "Password use to login to VM"
}

variable "application_port" {
  default     = "80"
  description = "Nginx listening port"
}

variable "lb_frontend_port" {
  default     = "8080"
  description = "Default load balancer frontend port"
}

variable "lb_sku_type" {
  default = "Standard"
  description = "Type of load balancer"
}

variable "default_environment" {
  default = "Development"
  description = "Default environment name"
}


