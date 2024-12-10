variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the app service plan"
  type        = string
}

variable "app_service_name" {
  description = "The name of the app"
  type        = string
}

variable "sql_server_name" {
  description = "The name of the mssql server"
  type        = string
}

variable "sql_database_name" {
  description = "The name of the sql database"
  type        = string
}

variable "sql_admin_user" {
  description = "The name of the admin user"
  type        = string
}

variable "sql_admin_password" {
  description = "The password of the admin user"
  type        = string
}

variable "firewall_rule_name" {
  description = "The name of the firewall rule"
  type        = string
}

variable "github_repository_address" {
  description = "The address of the github repository"
  type        = string
}