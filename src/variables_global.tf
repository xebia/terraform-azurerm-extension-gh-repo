# Global variables that come from the spoke deployment
variable "service_principal_client_id" {
  description = "The client ID of the service principal of the spoke."
  type        = string
}

variable "azure_tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}
