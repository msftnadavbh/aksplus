variable "enabled" {
  default = false
}
variable "suffix" {}
variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {}
variable "vm_size" {
  default = "Standard_B1s"
}
variable "admin_username" {
  default = "azadmin"
}
variable "admin_public_key" {}