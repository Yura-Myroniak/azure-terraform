variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "client_ip" {
  type        = string
  description = "Your public IPv4 address"
}