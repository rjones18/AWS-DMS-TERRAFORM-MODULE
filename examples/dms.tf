module "dms_pg_to_pg" {
  source = "./modules/dms"

  # ————————————————————————————————
  # 1) Core identifiers & networking
  replication_instance_id     = "dms-repl-instance"
  replication_subnet_group_id = "dms-subnet-group"
  subnet_ids                  = [data.aws_subnet.data-a.id, data.aws_subnet.data-b.id]
  vpc_security_group_ids      = [aws_security_group.database-security-group.id]

  # ————————————————————————————————
  # 2) Endpoint credentials & connection info
  engine_name           = "postgres"
  port                  = 5432
  ssl_mode              = "require"

  source_server_name    = aws_db_instance.database-instance.address
  source_database_name  = "edu"
  source_username       = "edu"
  source_password       = local.rds_credentials.password

  target_server_name    = aws_db_instance.database-instance2.address
  target_database_name  = "edu"
  target_username       = "edu"
  target_password       = local.rds_credentials2.password

  # ————————————————————————————————
  # 3) Replication task settings
  replication_task_id   = "rds-to-rds-task"

  # supply your JSON (or rely on module defaults if you add them there)
  table_mappings        = jsonencode({
    rules = [{
      "rule-type"      = "selection"
      "rule-id"        = "1"
      "rule-name"      = "include-all"
      "object-locator" = { "schema-name" = "%", "table-name" = "%" }
      "rule-action"    = "include"
    }]
  })

  replication_task_settings = jsonencode({
    TargetMetadata              = { FullLobMode = true, SupportLobs = true }
    FullLoadSettings            = { TargetTablePrepMode = "DROP_AND_CREATE" }
    Logging                     = { EnableLogging = true }
    ValidationSettings          = { EnableValidation = true }
    PreMigrationAssessmentRun   = { EnableAssessmentRun = true }
    ErrorBehavior               = { FailOnNoTablesCaptured = false }
  })
}

