resource "azurerm_app_service" "app" {
  name                = var.name_override != "" ? var.name_override : format("%s%03d%s", local.name, count.index + 1, var.name_suffix)
  count               = var.num
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.plan
  enabled             = "true"

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(var.app_settings, local.secure_app_settings, local.app_settings)

  lifecycle {
    ignore_changes = [
      id,
      app_service_plan_id,
      tags,
      app_settings,
    ]
  }

  https_only = "true"

  dynamic "storage_account" {
    for_each = var.storage_accounts
    content {
      name         = storage_account.value.name
      type         = storage_account.value.type
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = storage_account.value.access_key
      mount_path   = storage_account.value.mount_path
    }
  }

  site_config {
    always_on        = "true"
    app_command_line = var.command
    php_version      = var.win_php_version
    linux_fx_version = local.linux_fx_version
    http2_enabled    = var.http2_enabled
    ftps_state       = var.ftps_state

    dynamic "ip_restriction" {
      for_each = local.ip_restrictions
      content {
        ip_address                = ip_restriction.value
        virtual_network_subnet_id = null
      }
    }

    dynamic "ip_restriction" {
      for_each = var.virtual_network_subnet_ids
      content {
        virtual_network_subnet_id = ip_restriction.value
      }
    }

    default_documents = [
      "index.html",
      "index.php",
    ]
  }

  tags = merge({
    InfrastructureAsCode = "True"
  }, var.tags)
}
# commenting AD group creation and IAM permissions assignment code
/*resource "azuread_group" "WebsiteContributor" {
  name = format("g%s%s%s_AZ_WebsiteContributor", local.default_rgid, local.env_id, local.rg_type)
}

resource "azurerm_role_assignment" "WebsiteContributor" {
  scope                = format("/subscriptions/%s/resourceGroups/%s", var.subscription_id, var.rg_name)
  role_definition_name = "Website Contributor"
  principal_id         = azuread_group.WebsiteContributor.id
}
*/
  
# Should support using plans in a different subscription from web app
data "azurerm_app_service_plan" "app" {
  name                = local.plan_name
  resource_group_name = local.plan_rg
}

data "azurerm_container_registry" "acr" {
  count               = var.azure_registry_name != "" && var.azure_registry_rg != "" ? 1 : 0
  name                = var.azure_registry_name
  resource_group_name = var.azure_registry_rg
}

data "azurerm_client_config" "current" {}
