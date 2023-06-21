locals {

  policy_bool = flatten([for key, value in var.recovery_services_vault : [
    for item in value.backup_policy_vm : item]]) == null ? false : true

  backup_policy_vm = local.policy_bool == false ? null : flatten([for key, value in var.recovery_services_vault : [
    for k, v in value.backup_policy_vm : {
      vault_name = value.name
      create = v.create
      resource_group_name = value.resource_group_name
      name = v.name
      policy_type = v.policy_type
      timezone = v.timezone
      env_policy = v.env_policy
      instant_restore_resource_group = v.instant_restore_resource_group
      backup = v.env_policy == "prod" ? local.prod.backup : v.env_policy == "dev" ? local.dev.backup : v.backup
      retention_daily = v.env_policy == "prod" ? local.prod.retention_daily : v.env_policy == "dev" ? local.dev.retention_daily : v.retention_daily
      retention_weekly = v.env_policy == "prod" ? local.prod.retention_weekly : v.env_policy == "dev" ? local.dev.retention_weekly : v.retention_weekly
      retention_monthly = v.env_policy == "prod" ? local.prod.retention_monthly : v.retention_monthly
      retention_yearly = v.env_policy == "prod" ? local.prod.retention_yearly : v.retention_yearly
    }]
  ])


  backup_protected_vm = local.backup_policy_vm == null ? null : flatten([for key, value in var.recovery_services_vault : [
    for index, val in value.backup_policy_vm : [
      for k, v in val.backup_protected_vm : [
        for id in v.source_vm_id : {
          policy_create = val.create
          resource_group_name = value.resource_group_name
          recovery_vault_name = value.name
          policy_name = val.name
          source_vm_id = id
      }]
  ]]])

### Políticas de backup para DEV e TEST ###
  dev = {
    backup = {
      frequency = "Daily"
      time = "00:30"
    }
    retention_daily = {
      count = 15
    }
    retention_weekly = {
      count = 2
      weekdays = tolist(["Sunday"])
    }
  }
  
### Políticas de backup para PROD ###
  prod = {
    backup = {
      frequency = "Daily"
      time = "00:30"
    }
    retention_daily = {
      count = 30
    }
    retention_weekly = {
      count = 4
      weekdays = tolist(["Sunday"])
    }
    retention_monthly = {
      count = 2
      weekdays = tolist(["Sunday"])
      weeks = tolist(["First"])
    }
    retention_yearly = {
      count = 1
      months = tolist(["January"])
      weekdays = tolist(["Sunday"])
      weeks = tolist(["First"])
    }
  }
}
