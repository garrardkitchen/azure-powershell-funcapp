data "azurerm_virtual_machine" "vm" {
  name                = var.VM_NAME
  resource_group_name = var.RESOURCE_GROUP
}