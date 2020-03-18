resource "azurerm_role_assignment" "role_assignment" {
  for_each             = { for role in var.roles : role.role => role }
  scope                = var.scope
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
}
