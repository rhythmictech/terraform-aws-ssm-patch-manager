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
  count             = var.scan_enabled ? 1 : 0
  name              = "scan-${var.name}"
  cutoff            = var.scan_cutoff
  description       = "Maintenance window for scanning for patch compliance"
  duration          = var.scan_duration
  schedule          = var.scan_schedule
  schedule_timezone = var.schedule_timezone
  tags              = var.tags
}

resource "aws_ssm_maintenance_window" "install" {
  count             = var.install_enabled ? 1 : 0
  name              = "install-${var.name}"
  cutoff            = var.install_cutoff
  description       = "Maintenance window for applying patches"
  duration          = var.install_duration
  schedule          = var.install_schedule
  schedule_timezone = var.schedule_timezone
  tags              = var.tags
}

resource "aws_ssm_maintenance_window_target" "scan" {
  for_each      = var.scan_enabled ? var.platforms : []
  window_id     = aws_ssm_maintenance_window.scan[0].id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [each.key]
  }
}

resource "aws_ssm_maintenance_window_task" "scan" {
  count            = var.scan_enabled ? 1 : 0
  max_concurrency  = var.max_scan_concurrency
  max_errors       = var.max_scan_errors
  priority         = 1
  service_role_arn = var.service_role_arn
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  window_id        = aws_ssm_maintenance_window.scan[0].id

  targets {
    key    = "WindowTargetIds"
    values = [for val in aws_ssm_maintenance_window_target.scan : val.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment              = "Runs a compliance scan"
      service_role_arn     = var.scan_notification_role_arn
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

      dynamic "cloudwatch_config" {
        for_each = var.scan_cloudwatch_configs

        content {
          cloudwatch_log_group_name = cloudwatch_config.value.cloudwatch_log_group_name
          cloudwatch_output_enabled = cloudwatch_config.value.cloudwatch_output_enabled
        }
      }
    }
  }
}

resource "aws_ssm_maintenance_window_target" "install" {
  for_each      = var.install_enabled ? var.platforms : []
  window_id     = aws_ssm_maintenance_window.install[0].id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [each.key]
  }
}

resource "aws_ssm_maintenance_window_task" "install" {
  count            = var.install_enabled ? 1 : 0
  max_concurrency  = var.max_install_concurrency
  max_errors       = var.max_install_errors
  priority         = 1
  service_role_arn = var.service_role_arn
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  window_id        = aws_ssm_maintenance_window.install[0].id

  targets {
    key    = "WindowTargetIds"
    values = [for val in aws_ssm_maintenance_window_target.install : val.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment              = "Installs necessary patches"
      service_role_arn     = var.install_notification_role_arn
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

      dynamic "cloudwatch_config" {
        for_each = var.install_cloudwatch_configs

        content {
          cloudwatch_log_group_name = cloudwatch_config.value.cloudwatch_log_group_name
          cloudwatch_output_enabled = cloudwatch_config.value.cloudwatch_output_enabled
        }
      }
    }
  }
}
