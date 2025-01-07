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

resource "azurerm_resource_group" "resource_group" {
  name     = "messy-rg"
  location = var.location
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}