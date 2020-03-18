variable "scope" {}
variable "roles" {
  description = "List of roles that should be assigned to Azure AD object_ids."
  type        = list(object({ principal_id = string, role = string }))
  default     = []
}
