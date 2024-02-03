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
    environment = "Development"
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
    environment = "Development"
  }
}

# Deny Inbound Traffic from the Internet:
resource "azurerm_network_security_rule" "rule_deny_inbound" {
  name                        = "deny_internet_access"
  priority                    = 100
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

# Associate security group to rules
resource "azurerm_subnet_network_security_group_association" "nsg_association_01" {
  subnet_id                 = azurerm_subnet.subnet_nguyenlc1_udadevops_01.id
  network_security_group_id = azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01.id
  depends_on = [
    azurerm_network_security_group.sg_nguyenlc1_udadevops_prj1_01
  ]
}

# Create network interface
resource "azurerm_network_interface" "ni_nguyenlc1_udadevops_prj1_01" {
  count               = var.no_of_vm
  name                = "ni_nguyenlc1_udadevops_prj1_${count.index}" # Each VM will have dedicated NIC
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  ip_configuration {
    name                          = "BackendConfiguration"
    subnet_id                     = azurerm_subnet.subnet_nguyenlc1_udadevops_01.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    "environment" : "Development"
  }
}

# Create Public IP address
resource "azurerm_public_ip" "pip_nguyenlc1_udadevops_proj1_01" {
  name                = "pip_nguyenlc1_udadevops_proj1_01"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Basic"
  sku_tier            = "Regional"

  tags = {
    environment : "Development"
  }
}

# Create Load Balancer
resource "azurerm_lb" "lb_nguyenlc1_udadevops_proj1_01" {
  name                = "lb_nguyenlc1_udadevops_proj1_01"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip_nguyenlc1_udadevops_proj1_01.id
  }

  tags = {
    "environment" = "Development"
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

# Associate with network interface and backend pool
resource "azurerm_network_interface_backend_address_pool_association" "be_pool_association" {
  count                   = var.no_of_vm
  network_interface_id    = element(azurerm_network_interface.ni_nguyenlc1_udadevops_prj1_01.*.id, count.index)
  ip_configuration_name   = "BackendConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool_nguyenlc1_udadevops_proj1_01.id
}

# Availabity Set
resource "azurerm_availability_set" "as_nguyenlc1_udadevops_proj1_01" {
  name                         = "MyFirstAvailabilitySet"
  location                     = var.resource_group_location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2

  tags = {
    environment = "Development"
  }
}

# Create virtual machine as worker of backed pool
resource "azurerm_linux_virtual_machine" "vm-nguyenlc1_udadevops_prj1" {
  count               = var.no_of_vm # Create number of VM based on user input
  name                = "vm-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = var.vm_size

  network_interface_ids = [
    azurerm_network_interface.ni_nguyenlc1_udadevops_prj1_01[count.index].id,
  ]
  # Associate with Availability Set
  availability_set_id = azurerm_availability_set.as_nguyenlc1_udadevops_proj1_01.id

  # Use existing disk
  source_image_id = data.azurerm_image.my-image.id

  # Define more params 
  os_disk {
    name                 = "disk-${count.index}"
    disk_size_gb         = 50
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name                   = "web-application"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  tags = {
    environment = "Development"
  }

  # Make sure that network interface + Availability Set are created first.
  depends_on = [azurerm_network_interface.ni_nguyenlc1_udadevops_prj1_01, azurerm_availability_set.as_nguyenlc1_udadevops_proj1_01]
}
