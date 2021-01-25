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
  for_each         = var.platforms
  owner            = "AWS"
  name_prefix      = "AWS-"
  operating_system = each.key
  default_baseline = true
}

resource "aws_ssm_patch_group" "patchgroup" {
  for_each    = var.platforms
  baseline_id = data.aws_ssm_patch_baseline.this[each.key].id
  patch_group = each.key
}

resource "aws_ssm_maintenance_window" "scan" {
  name              = "scan-${var.name}"
  cutoff            = var.scan_cutoff
  description       = "Maintenance window for scanning for patch compliance"
  duration          = var.scan_duration
  schedule          = var.scan_schedule
  schedule_timezone = var.schedule_timezone
  tags              = var.tags
}

resource "aws_ssm_maintenance_window" "install" {
  name              = "install-${var.name}"
  cutoff            = var.install_cutoff
  description       = "Maintenance window for applying patches"
  duration          = var.install_duration
  schedule          = var.install_schedule
  schedule_timezone = var.schedule_timezone
  tags              = var.tags
}

resource "aws_ssm_maintenance_window_target" "scan" {
  for_each      = var.platforms
  window_id     = aws_ssm_maintenance_window.scan.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [each.key]
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

      dynamic "notification_config" {
        for_each = var.scan_notification_configs

        content {
          notification_arn    = notification_config.value.notification_arn
          notification_events = notification_config.value.notification_events
          notification_type   = notification_config.value.notification_type
        }
      }
    }
  }
}

resource "aws_ssm_maintenance_window_target" "install" {
  for_each      = var.platforms
  window_id     = aws_ssm_maintenance_window.install.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [each.key]
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

      dynamic "notification_config" {
        for_each = var.install_notification_configs

        content {
          notification_arn    = notification_config.value.notification_arn
          notification_events = notification_config.value.notification_events
          notification_type   = notification_config.value.notification_type
        }
      }
    }
  }
}
