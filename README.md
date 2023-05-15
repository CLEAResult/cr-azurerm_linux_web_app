# cr-azurerm_app_service

** WARNING! ** There may be breaking changes from time to time

Creates an azure app service web app on an existing app service plan.

This module is being updated relatively frequently and may be fragile
to unexpected inputs.  Reference the test fixture.

# Required Input Variables

* `plan` - Azure app service plan resource ID full path
* `rg_name` - Resource group name - doesn't have to be in the same resource group as the plan

Note that both the plan and resource group in `rg_name` must exist prior to creating the web app.  See https://github.com/CLEAResult/cr-terraform-examples for a working example.

Also, the location variable must match the location where the plan exists. Otherwise, you will get an error like the following, even though the reource and the managed identity will still be created:

`A resource with the same name cannot be created in location 'Central US'. Please select a new resource name."`

# Example

For a complete example, review the files in `test/fixture`.

```
variable "plan" {
  default = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Web/serverfarms/planname"
}

module "appservice" {
  source          = "git::ssh://git@github.com/clearesult/cr-azurerm_app_service.git"
  rg_name         = basename(module.rg.id)
  rgid            = var.rgid
  environment     = var.environment
  location        = var.location
  num             = 1
  slot_num        = var.slot_num
  plan            = var.plan
  subscription_id = var.subscription_id
  http2_enabled   = var.http2_enabled

  storage_accounts = [
    {
      name         = "data"
      type         = "AzureBlob"
      account_name = azurerm_storage_account.test.name
      share_name   = azurerm_storage_container.test.name
      access_key   = azurerm_storage_account.test.primary_access_key
      mount_path   = "/var/data"
    },
    {
      name         = "files"
      type         = "AzureFiles"
      account_name = azurerm_storage_account.test.name
      share_name   = azurerm_storage_share.test.name
      access_key   = azurerm_storage_account.test.primary_access_key
      mount_path   = "/var/files"
    }
  ]
}
```

