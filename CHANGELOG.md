[Unreleased]

[v1.7.5] - 2020-06-29

Other:

    - Minor variable documentation update

[v1.7.4] - 2020-05-04

Bug fixes:

    - Fix errors caused by empty default plan value (#12)

[v1.7.3, v1.5.2] - 2020-04-20

New features:

    - Add `name_suffix` and `name_override` variable support (PR #10)

[v1.7.2] - 2020-03-14

Breaking changes:

    - Requires azurerm provider >= 2.0

New features:

    - Add `virtual_network_subnet_ids` list variable to specify ip restrictions
    - Pass use_msi to the new provider block to support 2.0 azurerm provider

Other:

    - Add types to all variables
    - Add default value to http2_enabled

[v1.6.1] - 2020-03-10

Breaking changes:

    - `secret_name` variable removed

New features:

    - Support passing in key vault reference app settings as `secure_app_settings_refs` map variable for easier bootstrapping from other modules
    - Add `aspnet` to supported fx values

[v1.5.1] - 2020-02-25

Add DOTNETCORE as valid value for supported_fx

[v1.5.0] - 2020-01-13

Better container support for linux web apps:

    - Variable descriptions clarify valid container and non-container values for `fx` 
    - Setting the `fx` variable to `compose` or `kube` triggers base64 encode of `fx_version` variable
    - Set default value for storage_accounts variable 
    - Add ip_restrictions support in site_config
