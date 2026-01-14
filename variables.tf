# modules/dms/variables.tf
variable "replication_instance_id" {
  description = "Identifier for the DMS replication instance"
  type        = string
}

variable "replication_instance_class" {
  description = "Instance class for DMS replication instance"
  type        = string
  default     = "dms.t3.micro"
}

variable "allocated_storage" {
  description = "Storage (GB) for the replication instance"
  type        = number
  default     = 50
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DMS subnet group"
  type        = list(string)
}

variable "subnet_group_description" {
  description = "Description for the DMS subnet group"
  type        = string
  default     = "DMS replication subnet group"
}

variable "replication_subnet_group_id" {
  description = "ID for the DMS subnet group"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security groups for the replication instance"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Whether the replication instance is publicly accessible"
  type        = bool
  default     = false
}

# Endpoint connection settings
variable "engine_name" {
  description = "Database engine for endpoints (e.g., postgres)"
  type        = string
}

variable "port" {
  description = "Port for both source and target endpoints"
  type        = number
  default     = 5432
}

variable "ssl_mode" {
  description = "SSL mode for endpoints"
  type        = string
  default     = "require"
}

variable "source_server_name" {
  description = "Hostname or address of the source database"
  type        = string
}
variable "target_server_name" {
  description = "Hostname or address of the target database"
  type        = string
}

variable "source_database_name" {
  description = "Database name on the source endpoint"
  type        = string
}
variable "target_database_name" {
  description = "Database name on the target endpoint"
  type        = string
}

variable "source_username" {
  description = "Username for source database connection"
  type        = string
}
variable "target_username" {
  description = "Username for target database connection"
  type        = string
}

variable "source_password" {
  description = "Password for source database connection"
  type        = string
  sensitive   = true
}
variable "target_password" {
  description = "Password for target database connection"
  type        = string
  sensitive   = true
}

# Table mapping and task settings
variable "replication_task_id" {
  description = "Identifier for the DMS replication task"
  type        = string
}

variable "migration_type" {
  description = "Type of migration (full-load, cdc, etc.)"
  type        = string
  default     = "full-load"
}

variable "table_mappings" {
  description = "JSON-encoded table mappings for the task"
  type        = string
  default     = <<TABLE_MAPPINGS
{
  "rules": [
    {
      "rule-type":      "selection",
      "rule-id":        "1",
      "rule-name":      "include-all",
      "object-locator": { "schema-name": "%", "table-name": "%" },
      "rule-action":    "include"
    }
  ]
}
TABLE_MAPPINGS
}

variable "replication_task_settings" {
  description = "JSON-encoded task settings"
  type        = string
  default     = <<TASK_SETTINGS
{
  "TargetMetadata": {
    "FullLobMode": true,
    "SupportLobs": true
  },
  "FullLoadSettings": {
    "TargetTablePrepMode": "DROP_AND_CREATE"
  },
  "Logging": {
    "EnableLogging": true
  },
  "ValidationSettings": {
    "EnableValidation": true
  },
  "PreMigrationAssessmentRun": {
    "EnableAssessmentRun": true
  },
  "ErrorBehavior": {
    "FailOnNoTablesCaptured": false
  }
}
TASK_SETTINGS
}


# CloudWatch Log retention
variable "log_retention_in_days" {
  description = "Number of days to retain DMS task logs in CloudWatch"
  type        = number
  default     = 14
}