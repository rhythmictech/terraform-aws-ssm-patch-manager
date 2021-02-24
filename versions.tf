terraform {
  required_version = ">= 0.13.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.28" # v3.28.0 added significant improvements to plan-time validation for `ssm_maintenance_window_task`
    }
  }
}
