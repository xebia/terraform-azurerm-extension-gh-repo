terraform {
  required_version = "1.10.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.52.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "github" {
  # Configure your GitHub provider here
  # You can use environment variables:
  # GITHUB_TOKEN for authentication
  # GITHUB_OWNER for the organization
}