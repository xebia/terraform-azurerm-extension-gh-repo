output "repository_name" {
  description = "The name of the created GitHub repository."
  value       = local.github_repo.name
}

output "repository_url" {
  description = "The URL of the GitHub repository."
  value       = local.github_repo.html_url
}

output "repository_clone_url" {
  description = "The clone URL of the GitHub repository."
  value       = local.github_repo.git_clone_url
}

output "environment_name" {
  description = "The name of the GitHub environment."
  value       = github_repository_environment.spoke_environment.environment
}

output "federated_credential_environment_id" {
  description = "The ID of the federated identity credential for the environment."
  value       = azuread_application_federated_identity_credential.spoke_github_environment.id
}
