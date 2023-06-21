output "recovery_services_vault_ids" {
  value = [for k, v in azurerm_recovery_services_vault.this : v.id]
}

output "backup_policy_vm_ids" {
  value = merge({for k, v in azurerm_backup_policy_vm.this : v.name => v.id}, {for k, v in data.azurerm_backup_policy_vm.data : v.name => v.id})
}

output "policies_vms" {
  value = flatten([for key, value in var.recovery_services_vault : [
    for index, val in value.backup_policy_vm : [
      for k, v in val.backup_protected_vm : {
        "${val.name}" = v.source_vm_id
  }]]])
}

