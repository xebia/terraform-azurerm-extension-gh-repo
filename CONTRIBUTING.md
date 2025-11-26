# Contributing to terraform-azurerm-extension-gh-repo

## Using the Extension

1. This extension is designed to work with the [XMMS Landingzone Spoke deployment](https://dev.azure.com/xpiritmanagedservices/landingzone-core/_git/spokedeployment-tf?path=/infra/deploy/spoke)
2. Configure the extension in your spoke deployment JSON configuration file
3. The extension will be automatically included when enabled

## Simple Configuration

Add the following to your spoke deployment JSON configuration:

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "organization": "your-github-org",
      "repository_name": "your-repo-name"
    }
  }
}
```

## Configuration with Overrides

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "organization": "your-github-org",
      "repository_name": "your-repo-name",
      "repository_visibility": "private",
      "environment": "dev"
    }
  }
}
```

## Common Configuration

The `common.tf.sample` file contains organization-wide defaults:

```hcl
locals {
  ghinfo = {
    OrganizationName = "your-github-org"
    OidcIssuer = "https://token.actions.githubusercontent.com"
  }
}
```

## Extension Integration

In the [XMMS Landingzone Spoke deployment](https://dev.azure.com/xpiritmanagedservices/landingzone-core/_git/spokedeployment-tf?path=/infra/deploy/spoke), the extension is used via `ext_github.tf`:

```hcl
module "github_repository_configuration" {
  count  = try(local.jsonfile.extensions.github.enabled, false) == true ? 1 : 0
  source = "github.com/xebia/terraform-azurerm-extension-gh-repo//src"

  # Configuration from spoke deployment
  service_principal_client_id = module.privileges_service_principal.resSPNPrincipal.client_id
  github_organization         = try(local.jsonfile.extensions.github.organization, local.ghinfo.OrganizationName)
  github_repo_name           = local.jsonfile.extensions.github.repository_name
  # ... other variables
}
```

## Development

1. Make changes to the Terraform module in the `/src` folder
2. Update examples in the `/examples` folder
3. Test with the example configuration
4. Update documentation in README.md

## GitHub Provider Configuration

When using this extension, ensure your Terraform execution environment has proper GitHub provider configuration:

- Set `GITHUB_TOKEN` environment variable with a GitHub personal access token
- Ensure the token has appropriate permissions for repository creation and management
- For organization repositories, ensure the token has organization permissions

## Required Permissions

The GitHub token used must have the following permissions:
- Repository creation
- Repository settings management  
- Actions secrets management

## Testing

To test the extension:

1. Navigate to `examples/defaults`
2. Configure your GitHub provider credentials (`GITHUB_TOKEN`)
3. Update the example configuration as needed
4. Run `terraform init && terraform plan && terraform apply`

## Support

For issues or questions about this extension, please create an issue in this repository.