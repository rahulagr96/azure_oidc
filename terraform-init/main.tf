terraform {
  required_version = "~> 1.6.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.77.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

variable "location" {
  description = "Region location"
  default     = "West Europe"
}

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
  name     = "cleantidy-rg"
  location = var.location
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                              = "cleantidysa"
  resource_group_name               = azurerm_resource_group.resource_group.name
  location                          = var.location
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  infrastructure_encryption_enabled = false
  cross_tenant_replication_enabled  = true
  account_replication_type          = "LRS"
  allow_nested_items_to_be_public   = false
  min_tls_version                   = "TLS1_2"

  lifecycle {
    ignore_changes = [
      tags["ContactEmailAddress"]
    ]
  }
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 10
    }
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_management_policy" "storagepolicy" {
  storage_account_id = azurerm_storage_account.tfstate.id
  rule {
    name    = "DeletePreviousVersions"
    enabled = true
    filters {
      blob_types = ["blockBlob", "appendBlob"]
    }
    actions {
      version {
        delete_after_days_since_creation = 30
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "cleantidy-tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}