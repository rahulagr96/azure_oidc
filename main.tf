# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Retrieve the client configuration
data "azurerm_client_config" "current" {}

# Retrieve the primary Azure subscription
data "azurerm_subscription" "primary" {}

# Create the Azure AD App Registration
resource "azuread_application" "github_oidc_app" {
  display_name = "github-oidc-app"
  owners       = var.app_registration_owners
}

# Create the Service Principal for the App Registration
resource "azuread_service_principal" "github_oidc_sp" {
  client_id    = azuread_application.github_oidc_app.client_id
  owners       = var.app_registration_owners
  use_existing = true
}

# Assign a role to the Service Principal (e.g. Contributor role)
resource "azurerm_role_assignment" "github_oidc_role_assignment" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_oidc_sp.object_id
}

# Create a Federated Identity Credential for GitHub Actions OIDC
resource "azuread_application_federated_identity_credential" "example" {
  application_id = azuread_application.github_oidc_app.id
  display_name   = "github-oidc-credential"
  description    = "Contains the federeted creds for github"

  # Issuer URL for GitHub OIDC tokens
  issuer = "https://token.actions.githubusercontent.com"

  # Subject format for GitHub Actions (adjust to your repository and branch)
  subject = "repo:rahulagr96/azure_oidc:ref:refs/heads/main"

  # Audience for Azure AD token exchange
  audiences = ["api://AzureADTokenExchange"]
}


# Output important values for use in GitHub Secrets or elsewhere
output "client_id" {
  value = azuread_application.github_oidc_app.client_id
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "subscription_id" {
  value = data.azurerm_subscription.primary.subscription_id
}
