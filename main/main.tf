##################################################################################
# LOCALS
##################################################################################

locals {
  resource_group_name = "${var.naming_prefix}-${random_integer.name_suffix.result}"
}

resource "random_integer" "name_suffix" {
  min = 10000
  max = 99999
}

##################################################################################
# VIRTUAL NETWORK
##################################################################################
resource "azurerm_virtual_network" "example" {
  name                = "my-vnet-01"
  location            = "australiaeast"
  resource_group_name = "infra-rg"
  address_space       = ["10.0.0.0/16"]
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "fw-subnet"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "gw-subnet"
    address_prefixes = ["10.0.2.0/24"]
    #security_group   = azurerm_network_security_group.example.id
  }

  subnet {
    name             = "vm-subnet"
    address_prefixes = ["10.0.3.0/24"]
    #security_group   = azurerm_network_security_group.example.id
  }

  subnet {
    name             = "pe-subnet"
    address_prefixes = ["10.0.4.0/24"]
    #security_group   = azurerm_network_security_group.example.id
  }

  subnet {
    name             = "app-subnet"
    address_prefixes = ["10.0.5.0/24"]
    #security_group   = azurerm_network_security_group.example.id
  }

  subnet {
    name             = "db-subnet"
    address_prefixes = ["10.0.6.0/24"]
    #security_group   = azurerm_network_security_group.example.id
  }



  tags = {
    environment = "Production"
  }
}

##################################################################################
# VIRTUAL DESKTOP
##################################################################################

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "ws-01"
  location            = var.location
  resource_group_name = "avd-rg"
}

resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  name                             = "pd-hp-01"
  location                         = var.location
  resource_group_name              = "avd-rg"
  type                             = "Personal"
  load_balancer_type               = "Persistent"
  validate_environment             = true
  personal_desktop_assignment_type = "Automatic"

  tags = {
    owner       = "martinyang"
    cost_center = "108"
    workload    = "VDI"
  }
}

resource "azurerm_virtual_desktop_application_group" "desktopapp" {
  name                = "desktop-app-group"
  location            = var.location
  resource_group_name = "avd-rg"
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktopapp.id
}

##################################################################################
# LOG ANALYTICS WORKSPACE
##################################################################################

resource "azurerm_log_analytics_workspace" "example" {
  name                = "mylab-law-01"
  location            = var.location
  resource_group_name = "infra-rg"
  sku                 = "PerGB2018"

  retention_in_days = 30

  tags = {
    environment = "production"
    workload    = "log"
  }
}
