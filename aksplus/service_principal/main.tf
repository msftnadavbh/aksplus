provider "azuread" {
  version = "~> 0.7"
}

data "azurerm_subscription" "this" {
}

# Create Azure AD Application
resource "azuread_application" "application" {
  name = var.name
}

# Create Service Principal associated with the Azure AD App
resource "azuread_service_principal" "sp" {
  application_id = azuread_application.application.application_id
}

# Generate random string to be used for service principal password
resource "random_string" "random" {
  length = 32
}

# Create service principal password
resource "azuread_service_principal_password" "password" {
  service_principal_id = azuread_service_principal.sp.id
  value                = random_string.random.result
  end_date_relative    = "8760h"
}

module "spra" {
  source = "../role_assignment"
  scope  = data.azurerm_subscription.this.id
  roles = [
    {
      principal_id = azuread_service_principal.sp.id
      role      = "Contributor"
    }
  ]
}