output "created_user" {
  value = azuread_user.user1.user_principal_name
}

output "temporary_password" {
  value     = random_password.user1_password.result
  sensitive = true
}

output "group_name" {
  value = azuread_group.it_lab_admins.display_name
}