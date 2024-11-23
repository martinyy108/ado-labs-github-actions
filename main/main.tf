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

resource "azurerm_virtual_network" "main" {
  name                = "my-vnet-01"
  address_space       = ["172.16.0.0/21"]
  location            = var.location
  resource_group_name = "infra-rg"

  subnet {
    name             = "firewallsubnet"
    address_prefixes = "172.16.0.0/24"
  }

  subnet {
    name             = "vpngatewaysubnet"
    address_prefixes = "172.16.1.0/24"
  }

  subnet {
    name             = "vmssubnet"
    address_prefixes = "172.16.2.0/24"
  }

  subnet {
    name             = "privateendpointssubnet"
    address_prefixes = "172.16.3.0/24"
  }

  subnet {
    name             = "appservicessubnet"
    address_prefixes = "172.16.4.0/24"
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
  }
}
