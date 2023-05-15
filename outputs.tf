output "id" {
  value = azurerm_app_service.app.*.id
}

output "app_service_default_url" {
  value = azurerm_app_service.app.*.default_site_hostname
}

output "outbound_ip_addresses" {
  value = azurerm_app_service.app.*.outbound_ip_addresses
}

output "msi_principal_id" {
  value = azurerm_app_service.app[0].identity[0].principal_id
}

output "msi_tenant_id" {
  value = azurerm_app_service.app[0].identity[0].tenant_id
}

output "appServiceName" {
  value = azurerm_app_service.app.*.name
}
