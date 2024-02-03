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
  default     = 2
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


