resource "azurerm_recovery_services_vault" "this" {
  for_each = {for vault in var.recovery_services_vault : vault.name => vault} == null ? {} : {for vault in var.recovery_services_vault : vault.name => vault if vault.create == true}
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  soft_delete_enabled = each.value.soft_delete_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  immutability        = lookup(each.value, "immutability", null)
  storage_mode_type   = each.value.storage_mode_type
  cross_region_restore_enabled = each.value.cross_region_restore_enabled
  classic_vmware_replication_enabled = lookup(each.value, "classic_vmware_replication_enabled", null)

  dynamic "identity" {
    for_each = each.value.identity[*]
    content {
      type = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", [])
    }
  }

  dynamic "encryption" {
    for_each = each.value.encryption[*]
    content {
      key_id = encryption.value.key_id
      infrastructure_encryption_enabled = encryption.value.infrastructure_encryption_enabled
      user_assigned_identity_id = lookup(encryption.value, "user_assigned_identity_id", null)
      use_system_assigned_identity = lookup(encryption.value, "use_system_assigned_identity", true)
    }
  }

  dynamic "monitoring" {
    for_each = each.value.monitoring[*]
    content {
      alerts_for_all_job_failures_enabled = lookup(monitoring.value, "alerts_for_all_job_failures_enabled", true)
      alerts_for_critical_operation_failures_enabled = lookup(monitoring.value, "alerts_for_critical_operation_failures_enabled", true)
    }    
  }

  tags = var.tags
}

resource "azurerm_backup_policy_vm" "this" {
  for_each = local.backup_policy_vm != null ? {for policy in local.backup_policy_vm : policy.name => policy if policy.create == true} : {}
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  recovery_vault_name = each.value.vault_name
  policy_type         = each.value.policy_type
  timezone            = each.value.timezone
  instant_restore_retention_days = lookup(each.value, "instant_restore_retention_days", null)

  dynamic "backup" {
    for_each = each.value.backup[*]
    content {
      frequency = backup.value.frequency
      time      = backup.value.time
    }
  }
    
  dynamic "retention_daily" {
    for_each = each.value.retention_daily[*]
    content {
      count = retention_daily.value.count
    }
  }

  dynamic "retention_weekly" {
    for_each = each.value.retention_weekly[*]
    content {
      count    = retention_weekly.value.count
      weekdays = retention_weekly.value.weekdays
    }
  }
  
  dynamic "retention_monthly" {
    for_each = each.value.retention_monthly[*]
    content {
      count    = retention_monthly.value.count
      weekdays = lookup(retention_monthly.value, "weekdays", [])
      weeks    = lookup(retention_monthly.value, "weeks", [])
    }
  }

  dynamic "retention_yearly" {
    for_each = each.value.retention_yearly[*]
    content {
      count    = retention_yearly.value.count
      months   = retention_yearly.value.months
      weekdays = lookup(retention_yearly.value, "weekdays", [])
      weeks    = lookup(retention_yearly.value, "weeks", [])
    }
  }

  depends_on = [ azurerm_recovery_services_vault.this ]
}

resource "azurerm_backup_protected_vm" "this" {
  for_each = local.backup_protected_vm != null ? {for k, v in local.backup_protected_vm : k => v} : {}
  resource_group_name = each.value.resource_group_name
  recovery_vault_name = each.value.recovery_vault_name
  source_vm_id        = lookup(each.value, "source_vm_id", [])
  backup_policy_id    = lookup(each.value, "backup_policy_id", []) != [] ? each.value.backup_policy_id : each.value.policy_create == true ? azurerm_backup_policy_vm.this["${each.value.policy_name}"].id : data.azurerm_backup_policy_vm.data["${each.value.policy_name}"].id

  depends_on = [ azurerm_backup_policy_vm.this, data.azurerm_backup_policy_vm.data ]
}