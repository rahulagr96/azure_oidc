terraform {
  backend "azurerm" {
    storage_account_name = "cleantidysa"
    container_name       = "cleantidy-tfstate"
    key                  = "cleantidy-dev.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
    subscription_id      = "6b9229ec-4efc-4788-ab11-f2820b3c74fe"
    tenant_id            = "ee1faacd-8bbe-4894-b531-154f41b175ee"
  }
}