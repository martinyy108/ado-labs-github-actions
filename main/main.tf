##################################################################################
# LOCALS
##################################################################################


locals {
  resource_group_name   = "${var.naming_prefix}-${random_integer.name_suffix.result}"
  app_service_plan_name = "${var.naming_prefix}-${random_integer.name_suffix.result}"
  app_service_name      = "${var.naming_prefix}-${random_integer.name_suffix.result}"
}

resource "random_integer" "name_suffix" {
  min = 10000
  max = 99999
}

##################################################################################
# APP SERVICE
##################################################################################

resource "azurerm_resource_group" "app_service" {
  name     = local.resource_group_name
  location = var.location

  tags = {
    owner       = "martinyang"
    cost_center = "108"
  }
}

resource "azurerm_app_service_plan" "app_service" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.app_service.location
  resource_group_name = azurerm_resource_group.app_service.name

  sku {
    tier     = var.asp_tier
    size     = var.asp_size
    capacity = var.capacity
  }

  tags = {
    owner       = "martinyang"
    cost_center = "108"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = local.app_service_name
  location            = azurerm_resource_group.app_service.location
  resource_group_name = azurerm_resource_group.app_service.name
  app_service_plan_id = azurerm_app_service_plan.app_service.id

  source_control {
    repo_url           = "https://github.com/ned1313/nodejs-docs-hello-world"
    branch             = "main"
    manual_integration = true
    use_mercurial      = false
  }

  tags = {
    owner       = "martinyang"
    cost_center = "108"
  }
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "ws-01"
  location            = azurerm_resource_group.app_service.location
  resource_group_name = "avd-rg"
}

resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  name                 = "pd-hp-01"
  location             = azurerm_resource_group.app_service.location
  resource_group_name  = "avd-rg"
  type                 = "Personal"
  load_balancer_type   = "Persistent"
  validate_environment = true
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_host_pool.hostpool.id
}
