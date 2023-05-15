variable "rgid" {
  type        = string
  description = "RGID used for naming"
}

variable "location" {
  type        = string
  default     = "southcentralus"
  description = "Location for resources to be created"
}

variable "plan" {
  type        = string
  description = "Full Azure App Service Plan resource ID."
}

variable "num" {
  type    = number
  default = 1
}

variable "slot_num" {
  type        = number
  default     = 0
  description = "If set to a number greater than 0, create that many slots with generated names and the same configuration as the app. For now, this feature only support creating a slot on the first app service count (index 0).  If var.num is greater than 1, all slots will still be created on the index 0 app."
}

variable "name_prefix" {
  type        = string
  default     = ""
  description = "Allows users to override the standard naming prefix.  If left as an empty string, the standard naming conventions will apply."
}

variable "name_suffix" {
  type        = string
  default     = ""
  description = "Allows users to override the standard naming suffix, appearing after the instance count.  If left as an empty string, the standard naming conventions will apply."
}

variable "name_override" {
  type        = string
  default     = ""
  description = "If non-empty, will override all the standard naming conventions.  This should only be used when a product requires a specific database name."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment used in naming lookups"
}

variable "rg_name" {
  type        = string
  description = "Resource group name"
}

variable "subscription_id" {
  type        = string
  description = "Prompt for subscription ID"
}

variable "use_msi" {
  type        = bool
  default     = false
  description = "Use Managed Identity authentication for azurerm terraform provider. Default is false."
}

variable "http2_enabled" {
  type        = bool
  default     = false
  description = "Is HTTP2 Enabled on this App Service? Defaults to false."
}

variable "ip_restrictions" {
  type        = list(string)
  default     = []
  description = "A list of IP addresses in CIDR format that will be permitted access to the site.  All other IP addresses will be denied.  If you do not specify this variable, or if you specify an empty list and virtual_network_subnet_ids is also empty, all IP addresses will be permitted."
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of Azure virtual network subnet resource IDs that will be permitted access to the site.  All other IP addresses will be denied.  If you do not specify this variable, or if you specify an empty list and ip_restrictions is also empty, all IP addresses will be permitted."
}

variable "ftps_state" {
  type        = string
  description = "State of FTP / FTPS service for this App Service. Possible values include: AllAllowed, FtpsOnly and Disabled."
  default     = "FtpsOnly"
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Set app settings. These are avilable as environment variables at runtime."
}

variable "enable_storage" {
  type        = bool
  default     = false
  description = "Per Microsoft docs: If WEBSITES_ENABLE_APP_SERVICE_STORAGE setting is unspecified or set to true, the /home/ directory will be shared across scale instances, and files written will persist across restarts. Explicitly setting WEBSITES_ENABLE_APP_SERVICE_STORAGE to false will disable the mount."
}

variable "secure_app_settings_refs" {
  type        = map(string)
  default     = {}
  description = "Set sensitive app settings. Value be a valid key vault reference URI as documented. This can be obtained from a key vault secret data source ID."
}

variable "win_php_version" {
  type        = string
  default     = "7.2"
  description = "Used to select Windows web app PHP version.  Valid values are 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, and off.  Default is 7.2."
}

variable "fx" {
  type        = string
  default     = "php"
  description = "Used for Linux web app framework selection - ignored on Windows web apps. Default is PHP. Valid values for non-container deployments are `php` or `node`. Valid values for container deployments are: `docker`, `compose` or `kube`."
}

variable "fx_version" {
  type        = string
  default     = "7.2"
  description = "Used for Linux web app framework selection - ignored on Windows web apps.  Valid values are dependent on the `fx` variable value. If `fx` is `php`, `fx_value` would need to be a supported Azure web app PHP version (ie: 7.2). Similar if `fx` is `node`. If `fx` is `docker`, `fx_version` should be an empty string (if setting the container externally) or specify a valid container image name such as `appsvcsample/python-helloworld:latest`. Lastly, if `fx` is either `compose` or `kube`, `fx_version` should be a valid YAML configuration."
}

variable "port" {
  type        = string
  default     = null
  description = "The value of the expected container port number."
}

variable "docker_registry_username" {
  type        = string
  default     = null
  description = "The container registry username."
}

variable "docker_registry_url" {
  type        = string
  default     = "https://index.docker.io"
  description = "The container registry url."
}

variable "docker_registry_password" {
  type        = string
  default     = null
  description = "The container registry password."
}

variable "azure_registry_name" {
  type        = string
  default     = ""
  description = "The container registry name if using Azure Container Registry. Used with azure_registry_rg, will fill in the user/password using a terraform data source."
}

variable "azure_registry_rg" {
  type        = string
  default     = ""
  description = "The container registry resource group name if using Azure Container Registry. Used with azure_registry_name, will fill in the user/password using a terraform data source."
}

variable "start_time_limit" {
  type        = number
  default     = 230
  description = "Configure the amount of time (in seconds) the app service will wait before it restarts the container."
}

variable "command" {
  type        = string
  default     = ""
  description = "A command to be run on the container."
}

variable "storage_accounts" {
  type = list(object({
    name         = string
    type         = string
    account_name = string
    share_name   = string
    access_key   = string
    mount_path   = string
  }))
  default     = []
  description = "Used for Azure Linux web app Bring Your Own storage. Mounts an Azure Blob container or Azure Files share to a specific folder path on the web app."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the web app."
}

# Compute default name values
locals {
  plan_name = split("/", var.plan)[8]
  plan_rg   = split("/", var.plan)[4]

  env_id = lookup(module.naming.env-map, var.environment, "env")
  type   = lookup(module.naming.type-map, "azurerm_app_service", "typ")

  rg_type = lookup(module.naming.type-map, "azurerm_resource_group", "typ")

  default_rgid        = var.rgid != "" ? var.rgid : "norgid"
  default_name_prefix = format("c%s%s", local.default_rgid, local.env_id)

  name_prefix = var.name_prefix != "" ? var.name_prefix : local.default_name_prefix
  name        = format("%s%s", local.name_prefix, local.type)

  docker_registry_url      = var.docker_registry_url != "" ? var.docker_registry_url : var.azure_registry_name != "" && var.azure_registry_rg != "" ? data.azurerm_container_registry.acr[0].login_server : ""
  docker_registry_username = var.docker_registry_username != "" ? var.docker_registry_username : var.azure_registry_name != "" && var.azure_registry_rg != "" ? data.azurerm_container_registry.acr[0].admin_username : ""
  docker_registry_password = var.docker_registry_password != "" ? var.docker_registry_password : var.azure_registry_name != "" && var.azure_registry_rg != "" ? data.azurerm_container_registry.acr[0].admin_password : ""

  app_settings = {
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = var.start_time_limit
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = var.enable_storage
    "WEBSITES_PORT"                       = var.port
    "DOCKER_REGISTRY_SERVER_USERNAME"     = local.docker_registry_username
    "DOCKER_REGISTRY_SERVER_URL"          = local.docker_registry_url
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = local.docker_registry_password
  }

  fx = upper(var.fx)

  supported_fx = {
    ASPNET     = true
    COMPOSE    = true
    DOTNETCORE = true
    DOCKER     = true
    KUBE       = true
    NODE       = true
    PHP        = true
  }
  check_supported_fx = local.supported_fx[local.fx]

  fx_version = local.fx == "COMPOSE" || local.fx == "KUBE" ? base64encode(var.fx_version) : var.fx_version

  plan_kind = upper(data.azurerm_app_service_plan.app.kind)
  linux_fx_version = local.plan_kind == "WINDOWS" ? null : format("%s|%s", local.fx, local.fx_version)

  # Test key vault reference - error if doesn't match regex
  # If regex() returns false, execution will stop.
  # Otherwise, format proper key vault reference
  secure_app_settings = {
    for k, v in var.secure_app_settings_refs :
    replace(k, "/[^a-zA-Z0-9-]/", "-") => format("@Microsoft.KeyVault(SecretUri=%s)", v)
    if length(regexall("https://([A-Za-z][0-9A-Za-z-_]+)\\.vault\\.azure\\.net/secrets/([A-Za-z0-9-]{1,127})/(\\w{32})", v)) > 0
  }

  ip_restrictions = [
    for cidrprefix in var.ip_restrictions :
    regex("^(([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2])))$", cidrprefix)[0]
  ]
}

# This module provides a data map output to lookup naming standard references
module "naming" {
  source = "git::https://github.com/CLEAResult/cr-azurerm-naming.git?ref=v1.1.3"
}

