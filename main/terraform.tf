terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
  }

  backend "azurerm" {
    use_azuread_auth = true # Removes the need to use SA keys
  }
}

provider "azurerm" {
  features {

  }

  subscription_id = "b8e9db95-46a2-417b-84f4-4fca6c6a9733"
  tenant_id       = "e6bfbd64-c907-49d4-aea8-4e5b3839562e"
  # Configuration options
}
