terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azuread" {}

data "azuread_client_config" "current" {}

resource "random_password" "user1_password" {
  length  = 16
  special = true
}

resource "azuread_user" "user1" {
  user_principal_name = "az104-user1@${var.tenant_domain}"
  display_name        = "az104-user1"
  mail_nickname       = "az104-user1"
  password            = random_password.user1_password.result
  account_enabled     = true

  job_title        = "IT Lab Administrator"
  department       = "IT"
  usage_location   = "US"
  force_password_change = true
}

resource "azuread_invitation" "guest" {
  user_email_address = var.guest_email
  redirect_url       = "https://portal.azure.com"

  message {
    body = "Welcome to Azure and our group project"
  }
}

resource "azuread_group" "it_lab_admins" {
  display_name     = "IT Lab Administrators"
  description      = "Administrators that manage the IT lab"
  security_enabled = true

  owners = [
    data.azuread_client_config.current.object_id
  ]

  members = [
    azuread_user.user1.object_id,
    azuread_invitation.guest.user_id
  ]
}