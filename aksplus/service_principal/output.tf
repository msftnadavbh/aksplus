output "application_id" {
  value = azuread_application.application.application_id
}

output "service_principal_id" {
  value = azuread_service_principal.sp.id
}

output "service_principal_password" {
  value = azuread_service_principal_password.password.value
}