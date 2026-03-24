# Create a resource group in Azure
resource "azurerm_resource_group" "my_resource_group" {
  provider = azurerm.demo
  name     = "${var.workload_nickname}-rg-demo"
  location = "centralus"
}

# Put an Azure Static Web App into it
resource "azurerm_static_web_app" "my_static_web_app" {
  provider            = azurerm.demo
  name                = "${var.workload_nickname}-swa-demo"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  sku_tier            = "Free"
  sku_size            = "Free"
}

# Set a GitHub Actions secret on this repo so we can deploy into the SWA
resource "github_actions_secret" "gh_scrt_vm_username" {
  repository      = var.current_gh_repo
  secret_name     = "MY_AZURE_SWA_DEPLOYMENT_TOKEN"
  plaintext_value = azurerm_static_web_app.my_static_web_app.api_key
}