locals {
  platforms = {
    amazon_linux_2 = "AMAZON_LINUX_2"
    amazon_linux   = "AMAZON_LINUX"
    centos         = "CENTOS"
    oracle         = "ORACLE_LINUX"
    suse           = "SUSE"
    windows        = "WINDOWS"
    debian         = "DEBIAN"
    ubuntu         = "UBUNTU"
    rhel           = "REDHAT_ENTERPRISE_LINUX"
    macos          = "MACOS"
  }
}

data "aws_iam_policy_document" "ssm_maintenance_window" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ssm_maintenance_window" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.ssm_maintenance_window.json
  path               = "/system/"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "role_attach_ssm_mw" {
  role       = aws_iam_role.ssm_maintenance_window.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

data "aws_ssm_patch_baseline" "this" {
  for_each         = local.platforms
  owner            = "AWS"
  name_prefix      = "AWS-"
  operating_system = each.value
  default_baseline = true
}

resource "aws_ssm_patch_group" "patchgroup" {
  for_each    = local.platforms
  baseline_id = data.aws_ssm_patch_baseline.this[each.key].id
  patch_group = each.value
}

resource "aws_ssm_maintenance_window" "scan" {
  name              = "scan-${var.name}"
  cutoff            = 1
  description       = "Maintenance window for applying patches"
  duration          = 4
  schedule          = "cron(0 06 * * ? *)"
  schedule_timezone = "America/New_York"
  tags              = var.tags
}

resource "aws_ssm_maintenance_window" "install" {
  name              = "install-${var.name}"
  cutoff            = 1
  description       = "Maintenance window for applying patches"
  duration          = 3
  schedule          = "cron(0 22 * * ? *)"
  schedule_timezone = "America/New_York"
  tags              = var.tags
}

resource "aws_ssm_maintenance_window_target" "scan" {
  for_each      = local.platforms
  window_id     = aws_ssm_maintenance_window.scan.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [each.value]
  }
}

resource "aws_ssm_maintenance_window_task" "scan" {
  window_id        = aws_ssm_maintenance_window.scan.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = aws_iam_role.ssm_maintenance_window.arn
  max_concurrency  = var.max_scan_concurrency
  max_errors       = var.max_scan_errors

  targets {
    key    = "WindowTargetIds"
    values = [for val in aws_ssm_maintenance_window_target.scan : val.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment              = "Runs a compliance scan"
      output_s3_bucket     = var.log_bucket
      output_s3_key_prefix = var.scan_log_prefix
      timeout_seconds      = 120

      parameter {
        name   = "Operation"
        values = ["Scan"]
      }
    }
  }
}

resource "aws_ssm_maintenance_window_target" "install" {
  for_each      = local.platforms
  window_id     = aws_ssm_maintenance_window.install.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [each.value]
  }
}

resource "aws_ssm_maintenance_window_task" "install" {
  window_id        = aws_ssm_maintenance_window.scan.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = aws_iam_role.ssm_maintenance_window.arn
  max_concurrency  = var.max_install_concurrency
  max_errors       = var.max_install_errors

  targets {
    key    = "WindowTargetIds"
    values = [for val in aws_ssm_maintenance_window_target.install : val.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment              = "Installs necessary patches"
      output_s3_bucket     = var.log_bucket
      output_s3_key_prefix = var.install_log_prefix
      timeout_seconds      = 120

      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}
