resource "azurerm_resource_group" "rg" {
  name     = "${var.workstream}-RG"
  location = "North Europe"
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.workstream}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "Y1"
  os_type  = "Windows"
}

resource "azurerm_windows_function_app" "func" {
  name                       = var.workstream
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  site_config {
    always_on = false
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME         = "powershell"
    FUNCTIONS_WORKER_RUNTIME_VERSION = "7.2"
    AzureWebJobsStorage              = azurerm_storage_account.sa.primary_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.insights.instrumentation_key
    RESOURCE_GROUP                   = var.RESOURCE_GROUP
    VM_NAME                          = var.VM_NAME
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_source_control" "source_control" {
  app_id                 = azurerm_windows_function_app.func.id
  repo_url               = "https://github.com/garrardkitchen/azure-powershell-funcapp"
  branch                 = "main"
  use_manual_integration = true

  #   github_action_configuration {

  #     repository_url = "https://github.com/your-username/your-repo"
  #     branch         = "main"
  #     workflow_name  = "azure-functions-deploy.yml"
  #   }
}

resource "azurerm_application_insights" "insights" {
  name                = "${var.workstream}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_role_assignment" "vm_contributor" {
  scope                = azurerm_windows_function_app.func.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = data.azurerm_virtual_machine.vm.identity[0].principal_id
}

output "function_app_name" {
  value = azurerm_windows_function_app.func.name
}
