output "repository_url" {
  description = "The URL of the created GitHub repository"
  value       = module.github_repo_extension.repository_url
}

output "repository_clone_url" {
  description = "The clone URL of the GitHub repository"
  value       = module.github_repo_extension.repository_clone_url
}

output "federated_credential_main_id" {
  description = "The ID of the federated identity credential for main branch"
  value       = module.github_repo_extension.federated_credential_main_id
}