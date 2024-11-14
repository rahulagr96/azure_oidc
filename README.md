# azure_oidc

[![OIDC-test](https://github.com/rahulagr96/azure_oidc/actions/workflows/oidc_test.yml/badge.svg)](https://github.com/rahulagr96/azure_oidc/actions/workflows/oidc_test.yml)

## Important Terraform Commands
- `terraform init`: Initializes a new or existing Terraform configuration by downloading necessary plugins and setting up the backend.
- `terraform plan`: Creates an execution plan, showing what actions Terraform will take to achieve the desired state.
- `terraform fmt`: Formats the Terraform configuration files to a canonical format and style.
- `terraform validate`: Validates the Terraform configuration files for syntax and internal consistency.
- `terraform apply -auto-approve`: Applies the changes required to reach the desired state without prompting for confirmation.

---

###  OIDC In Azure


```terraform
# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```
- **provider "azurerm"**: This block configures the Azure Resource Manager (AzureRM) provider. It specifies the Azure subscription ID to use for deploying resources. The `features {}` block is required but can be left empty.

```terraform
# Retrieve the client configuration
data "azurerm_client_config" "current" {}
```
- **data "azurerm_client_config" "current"**: This data source retrieves information about the authenticated Azure client, such as the tenant ID and client ID. It is useful for referencing these values in other parts of the configuration.

```terraform
# Retrieve the primary Azure subscription
data "azurerm_subscription" "primary" {}
```
- **data "azurerm_subscription" "primary"**: This data source retrieves information about the primary Azure subscription, such as the subscription ID. It is useful for referencing these values in other parts of the configuration.

```terraform
# Create the Azure AD App Registration
resource "azuread_application" "github_oidc_app" {
  display_name = "github-oidc-app"
  owners       = var.app_registration_owners
}
```
- **resource "azuread_application" "github_oidc_app"**: This resource creates an Azure Active Directory (AD) application registration. The `display_name` is set to "github-oidc-app", and the `owners` are specified using a variable. This application can be used for OAuth2 authentication, among other things.

```terraform
# Create the Service Principal for the App Registration
resource "azuread_service_principal" "github_oidc_sp" {
  client_id    = azuread_application.github_oidc_app.client_id
  owners       = var.app_registration_owners
  use_existing = true
}
```
- **resource "azuread_service_principal" "github_oidc_sp"**: This resource creates a service principal for the Azure AD application. A service principal is an identity used by applications or services to access specific Azure resources. The `client_id` is set to the ID of the previously created Azure AD application. The `owners` are specified using a variable, and `use_existing` is set to `true` to use an existing service principal if it already exists.

```terraform
# Assign a role to the Service Principal (e.g., Contributor role)
resource "azurerm_role_assignment" "github_oidc_role_assignment" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_oidc_sp.object_id
}
```
- **resource "azurerm_role_assignment" "github_oidc_role_assignment"**: This resource assigns a role to the service principal. The `scope` is set to the ID of the primary Azure subscription. The `role_definition_name` is set to "Contributor", which grants the service principal the Contributor role. The `principal_id` is set to the ID of the previously created service principal.

```terraform
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
```
- **output "client_id"**: This output block outputs the client ID (application ID) of the Azure AD application. This value can be used in other scripts or configurations, such as GitHub Secrets.
- **output "tenant_id"**: This output block outputs the tenant ID of the authenticated Azure client. This value can also be used in other scripts or configurations.
- **output "subscription_id"**: This output block outputs the subscription ID of the primary Azure subscription. This value can also be used in other scripts or configurations.

### Summary
- The `main.tf` file configures the Azure provider, retrieves client and subscription information, creates an Azure AD application and service principal, assigns a role to the service principal, and outputs important values.
- Variables are used to make the configuration more flexible and reusable.
- The configuration is designed to set up an Azure AD application and service principal, assign the Contributor role to the service principal, and output the client ID, tenant ID, and subscription ID for further use.