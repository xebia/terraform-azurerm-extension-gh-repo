output "repository_name" {
  description = "The name of the created GitHub repository."
  value       = github_repository.spoke_repo.name
}

output "repository_url" {
  description = "The URL of the GitHub repository."
  value       = github_repository.spoke_repo.html_url
}

output "repository_clone_url" {
  description = "The clone URL of the GitHub repository."
  value       = github_repository.spoke_repo.git_clone_url
}

output "federated_credential_main_id" {
  description = "The ID of the federated identity credential for the main branch."
  value       = azuread_application_federated_identity_credential.spoke_github_main.id
}

output "federated_credential_environment_ids" {
  description = "The IDs of the federated identity credentials for environments."
  value       = { for env, cred in azuread_application_federated_identity_credential.spoke_github_environment : env => cred.id }
}