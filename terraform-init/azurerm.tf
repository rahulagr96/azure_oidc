# Define the custom roles to create. 
# Each block under 'custom_role_definitions' will create a specific role.
# Define Azure Role Assignments to create.
# Each block under 'role' will create a Role Assignment.

locals {
  assignments = {
    StorageBlobDataContributor = {
      scope                = azurerm_storage_account.tfstate.id
      role_definition_name = "Storage Blob Data Contributor"
      principal_ids        = "b4de87f3-124e-46c3-9e56-3ff7f3c429e6"
    }
    StorageBlobDelegator = {
      scope                = azurerm_storage_account.tfstate.id
      role_definition_name = "Storage Blob Delegator"
      principal_ids        = "b4de87f3-124e-46c3-9e56-3ff7f3c429e6"
    }
  }
}

resource "azurerm_role_assignment" "role_assignment" {
  for_each             = local.assignments
  scope                = each.value.scope
  principal_id          = each.value.principal_ids
  role_definition_name = lookup(each.value, "role_definition_name", null)
}