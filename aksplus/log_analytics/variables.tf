variable "name" {
  description = "(Required) Log Analytics workspace name"
}

variable "location" {
  description = "(Required) Location of the resources"
}

variable "resource_group_name" {
  description = "(Required) Resource group name"
}

variable "solution_plan_map" {
  description = "(Optional) Map structure containing the list of solutions to be enabled."
  type = map(any)
}