resource "azurerm_app_service_slot" "app" {
  name                = format("%s%03d-slot", local.name, count.index + 1)
  count               = var.slot_num
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.plan
  app_service_name    = basename(azurerm_app_service.app[0].id)
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

