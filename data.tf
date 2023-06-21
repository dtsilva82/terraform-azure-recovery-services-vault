data "azurerm_backup_policy_vm" "data" {
  for_each = local.backup_policy_vm != null ? {for policy in local.backup_policy_vm : policy.name => policy if policy.create == false} : {}
  name                = each.value.name
  recovery_vault_name = each.value.vault_name
  resource_group_name = each.value.resource_group_name
}