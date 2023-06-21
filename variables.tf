variable "location" {
  type = string
  default = "brazilsouth"
  description = "Região em que o recurso será criado ou recuperado"
}

variable "tags" {
  type = map(any)
  description = "Mapa com as tags relacionadas ao recurso principal"
}

variable "recovery_services_vault" {
  description = "Mapa de objetos com os argumentos de Recovery Services Vault"
  type = map(object({
    create = optional(bool, false)
    resource_group_name = optional(string)
    name = optional(string)
    sku = optional(string, "Standard")
    soft_delete_enabled = optional(bool, true)
    public_network_access_enabled = optional(bool, false)
    immutability = optional(string)
    storage_mode_type = optional(string, "ZoneRedundant")
    cross_region_restore_enabled = optional(bool, false)
    classic_vmware_replication_enabled = optional(bool)
    identity = optional(object({
      type = optional(string)
      identity_ids = optional(list(string))
    }))
    encryption = optional(object({
      key_id = optional(string)
      infrastructure_encryption_enabled = optional(bool)
      user_assigned_identity_id = optional(string)
      use_system_assigned_identity = optional(bool)
    }))
    monitoring = optional(object({
      alerts_for_all_job_failures_enabled = optional(bool)
      alerts_for_critical_operation_failures_enabled = optional(bool)
    }))
    backup_policy_vm = optional(map(object({
      create = optional(bool, false)
      name = optional(string)
      env_policy = optional(string, "") #valores aceitos prod ou dev(para dev ou test)
      policy_type = optional(string, "V2")
      timezone = optional(string, "E. South America Standard Time")
      instant_restore_retention_days = optional(number)
      backup = optional(object({
        frequency = optional(string)
        time = optional(string)
      }))
      instant_restore_resource_group = optional(object({
        prefix = optional(string)
        suffix = optional(string)
      }))
      retention_daily = optional(object({
        count = optional(number)
      }))
      retention_weekly = optional(object({
        count = optional(number)
        weekdays = optional(list(string))
      }))
      retention_monthly = optional(object({
        count = optional(number)
        weekdays = optional(list(string))
        weeks = optional(list(string))
      }))
      retention_yearly = optional(object({
        count = optional(number)
        months = optional(list(string))
        weekdays = optional(list(string))
        weeks = optional(list(string))
      }))
      backup_protected_vm = optional(map(object({
        policy_create       = optional(bool)
        resource_group_name = optional(string)
        recovery_vault_name = optional(string)
        source_vm_id        = optional(list(string))
        backup_policy_id    = optional(list(string))
      })))
    })))
  }))
  default = {
    "name" = {
      identity = {}
      encryption = {}
      monitoring = {}
      backup_policy_vm = {
          retention_daily = {}
          retention_weekly = {}
          retention_monthly = {}
          retention_yearly = {}
          instant_restore_resource_group = {}
      }
    }
  }
}


