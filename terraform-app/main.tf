provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "azuread" {
  tenant_id = "ee1faacd-8bbe-4894-b531-154f41b175ee"
}

# Retrieve the primary Azure subscription
data "azurerm_subscription" "primary" {}

resource "azurerm_resource_group" "resource_group" {
  name     = "test-rg"
  location = "West Europe"
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}