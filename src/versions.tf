terraform {
  required_version = "~> 1.1, <= 1.10.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.2"
    }
    github = {
      source  = "integrations/github"
      version = "6.8.3"
    }
  }
}
