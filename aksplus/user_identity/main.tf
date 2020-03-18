data "azurerm_subscription" "this" {
}

resource "azurerm_user_assigned_identity" "user_identity" {
  name = var.name
  resource_group_name = var.resource_group_name
  location            = var.location  
}

module "uira_subscription" {
  source = "../role_assignment"
  scope  = data.azurerm_subscription.this.id
  roles = [
    {
      principal_id = azurerm_user_assigned_identity.user_identity.principal_id
      role      = "Contributor"
    }
  ]
}

module "spra_ui" {
  source = "../role_assignment"
  scope  = azurerm_user_assigned_identity.user_identity.id
  roles = [
    {
      principal_id = var.principal_id
      role      = "Managed Identity Operator"
    }
  ]
}