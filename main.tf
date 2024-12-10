terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "36469129-d2a2-41ee-a196-7255709cab2d"
  features {
  }
}

resource "random_integer" "ri" {
  min = 10000 # set min value
  max = 99999 # set max value
}

resource "azurerm_resource_group" "daniorg" {
  location = var.resource_group_location                              # set location for resource group
  name     = "${var.resource_group_name}-${random_integer.ri.result}" # set name for the group with random integer
}

resource "azurerm_service_plan" "danioappsp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}" # set unique name with random integer generator
  resource_group_name = azurerm_resource_group.daniorg.name                        # set name of the resource
  location            = azurerm_resource_group.daniorg.location                    # set location of the resource group
  os_type             = "Linux"                                                    # set OS type
  sku_name            = "F1"                                                       # set subscription type
}

resource "azurerm_linux_web_app" "danioazurewebapp" {                        # set name of the web app resource - danioazurewebapp
  name                = "${var.app_service_name}${random_integer.ri.result}" # set random name using random integer generator
  resource_group_name = azurerm_resource_group.daniorg.name                  # set the name of the used resourece group
  location            = azurerm_service_plan.danioappsp.location             # set the location of the service plan
  service_plan_id     = azurerm_service_plan.danioappsp.id                   # set the id of the service plan

  site_config {
    application_stack {      # set app stack
      dotnet_version = "6.0" # set the dotnet version
    }
    always_on = false # app sleep when not used
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.danio_sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.daniodb.name};User ID=${azurerm_mssql_server.danio_sql.administrator_login};Password=${azurerm_mssql_server.danio_sql.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
    #                           resource title    resource name  specific property
  }
}

resource "azurerm_mssql_server" "danio_sql" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.daniorg.name
  location                     = azurerm_resource_group.daniorg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "daniodb" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.danio_sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  zone_redundant = false
  sku_name       = "S0"
}

resource "azurerm_mssql_firewall_rule" "daniofirewallrule" { # set firewall resource
  name             = var.firewall_rule_name                  # set name for firewall rule
  server_id        = azurerm_mssql_server.danio_sql.id       # set mssql server id
  start_ip_address = "0.0.0.0"                               # set start ip address for firewall rule - access from everywhere
  end_ip_address   = "0.0.0.0"                               # set end ip address - access from everywhere
}

resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.danioazurewebapp.id # set web app id
  repo_url               = var.github_repository_address             # set repo address
  branch                 = "main"                                    # set branch
  use_manual_integration = false
}