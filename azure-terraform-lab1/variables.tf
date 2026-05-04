variable "tenant_domain" {
  description = "Primary domain of Microsoft Entra ID tenant"
  type        = string
}

variable "guest_email" {
  description = "Email of invited guest user"
  type        = string
}

variable "guest_display_name" {
  description = "Display name of invited guest user"
  type        = string
}