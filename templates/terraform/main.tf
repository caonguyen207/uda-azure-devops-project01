# Get reference to existing image
data "azurerm_image" "my-image" {
  name                = var.vm_image_name
  resource_group_name = var.resource_group_name
}

# Create Virtual network and one subnet
resource "azurerm_virtual_network" "vnet_nguyenlc1_udadevops_01" {
  name                = "vnet_nguyenlc1_udadevops_01"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space       = ["192.168.0.0/16"]

  tags = {
    environment = var.default_environment
  }
}

# Create subnet
resource "azurerm_subnet" "subnet_nguyenlc1_udadevops_01" {
  name                 = "subnet_nguyenlc1_udadevops_01"
  virtual_network_name = azurerm_virtual_network.vnet_nguyenlc1_udadevops_01.name
  address_prefixes     = ["192.168.0.0/24"]
  resource_group_name  = var.resource_group_name

  depends_on = [azurerm_virtual_network.vnet_nguyenlc1_udadevops_01]
}

# Create network security group
resource "azurerm_network_security_group" "sg_nguyenlc1_udadevops_prj1_01" {
  name                = "sg_nguyenlc1_udadevops_prj1_01"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  tags = {
    environment = var.default_environment
  }
}

# Deny Inbound Traffic from the Internet:
resource "azurerm_network_security_rule" "deny_internet" {
  name                        = "deny_internet"
  priority                    = 121
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01.name
}

# Allow traffic within the Same Virtual Network
resource "azurerm_network_security_rule" "allow_internal_inbound" {
  name                        = "allow_internal_inbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*" 
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01.name
}

# Allow HTTP Traffic from the Load Balancer to the VMs
resource "azurerm_network_security_rule" "allow_inbound_lb" {
  name                        = "allow_lb_inbound"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01.name
}

# Allow outbound traffic within the Same Virtual Network
resource "azurerm_network_security_rule" "allow_internal_outbound" {
  name                        = "allow_internal_outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01.name
}

# Associate security group to rules
resource "azurerm_subnet_network_security_group_association" "nsg_association_01" {
  subnet_id                 = azurerm_subnet.subnet_nguyenlc1_udadevops_01.id
  network_security_group_id = azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01.id
  depends_on = [
    azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01
  ]
}

# Create Public IP address
resource "azurerm_public_ip" "pip_nguyenlc1_udadevops_proj1_01" {
  name                = "pip_nguyenlc1_udadevops_proj1_01"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.lb_sku_type

  tags = {
    environment : var.default_environment
  }
}

# Create Load Balancer
resource "azurerm_lb" "lb_nguyenlc1_udadevops_proj1_01" {
  name                = "lb_nguyenlc1_udadevops_proj1_01"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku = var.lb_sku_type

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip_nguyenlc1_udadevops_proj1_01.id
  }

  tags = {
    "environment" = var.default_environment
  }
}

# Define health probe
resource "azurerm_lb_probe" "lb_probe_nguyenlc1_proj1_01" {
  loadbalancer_id = azurerm_lb.lb_nguyenlc1_udadevops_proj1_01.id
  name            = "running-probe"
  port            = var.application_port
  interval_in_seconds = 10
  protocol = "Tcp"
}

# Create LoadBalancer Rules
resource "azurerm_lb_rule" "lb_rule_nguyenlc1_udadevops_proj1_01" {
  loadbalancer_id                = azurerm_lb.lb_nguyenlc1_udadevops_proj1_01.id
  name                           = "LoadBalancerRule"
  protocol                       = "Tcp"
  frontend_port                  = var.lb_frontend_port
  backend_port                   = var.application_port
  frontend_ip_configuration_name = "PublicIPAddress"

  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_pool_nguyenlc1_udadevops_proj1_01.id]
  probe_id = azurerm_lb_probe.lb_probe_nguyenlc1_proj1_01.id

  depends_on = [
    azurerm_lb.lb_nguyenlc1_udadevops_proj1_01
  ]
}

# Load Balancer Backend Pool
resource "azurerm_lb_backend_address_pool" "lb_pool_nguyenlc1_udadevops_proj1_01" {
  loadbalancer_id = azurerm_lb.lb_nguyenlc1_udadevops_proj1_01.id
  name            = "LBBackEndAddressPool"
}

# Use VMSS instead of AS, number of instances can change in variable environment.
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "vmss-app"
  resource_group_name             = var.resource_group_name
  location                        = var.resource_group_location
  sku                             = var.vm_size
  instances                       = var.no_of_vm
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_id = data.azurerm_image.my-image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 30
  }

  network_interface {
    name                      = "vmss-app-ni"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet_nguyenlc1_udadevops_01.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_pool_nguyenlc1_udadevops_proj1_01.id]
    }
  }
  tags = {
    environment = var.default_environment
  }
}
