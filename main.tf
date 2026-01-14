# Terraform DMS Module: modules/dms/main.tf

#########################################
# IAM Roles & Attachments               #
#########################################
# Role that allows DMS to manage ENIs in your VPC
resource "aws_iam_role" "vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "dms.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach the AWS-managed policy for VPC management
resource "aws_iam_role_policy_attachment" "vpc_role_policy" {
  role       = aws_iam_role.vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# Role that allows DMS to publish logs to CloudWatch Logs
resource "aws_iam_role" "cloudwatch_logs_role" {
  name = "dms-cloudwatch-logs-role-${var.replication_instance_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "dms.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach the AWS-managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "cloudwatch_logs_role_policy" {
  role       = aws_iam_role.cloudwatch_logs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

#########################################
# Networking & Subnet Group             #
#########################################
resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = var.replication_subnet_group_id
  subnet_ids                           = var.subnet_ids
  replication_subnet_group_description = var.subnet_group_description
}

#########################################
# Replication Instance                  #
#########################################
resource "aws_dms_replication_instance" "this" {
  replication_instance_id   = var.replication_instance_id
  replication_instance_class = var.replication_instance_class
  allocated_storage         = var.allocated_storage
  vpc_security_group_ids    = var.vpc_security_group_ids
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id
  publicly_accessible       = var.publicly_accessible
  # Assign both roles to the instance
#   iam_authentication        = "SIMPLE"
}

#########################################
# CloudWatch Log Group for Task Logs    #
#########################################
resource "aws_cloudwatch_log_group" "task_logs" {
  name              = "/aws/dms/replication-tasks/${var.replication_instance_id}"
  retention_in_days = var.log_retention_in_days
}

#########################################
# Source & Target Endpoints             #
#########################################
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.replication_instance_id}-source"
  endpoint_type = "source"
  engine_name   = var.engine_name

  username      = var.source_username
  password      = var.source_password
  server_name   = var.source_server_name
  port          = var.port
  database_name = var.source_database_name
  ssl_mode      = var.ssl_mode
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = "${var.replication_instance_id}-target"
  endpoint_type = "target"
  engine_name   = var.engine_name

  username      = var.target_username
  password      = var.target_password
  server_name   = var.target_server_name
  port          = var.port
  database_name = var.target_database_name
  ssl_mode      = var.ssl_mode
}

#########################################
# Replication Task                      #
#########################################
resource "aws_dms_replication_task" "this" {
  replication_task_id      = var.replication_task_id
  migration_type           = var.migration_type
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn

  table_mappings           = var.table_mappings
  replication_task_settings = var.replication_task_settings
  # NEW: Automatically start the task after create
  start_replication_task    = true
}