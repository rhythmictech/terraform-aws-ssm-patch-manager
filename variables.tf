variable "name" {
  default     = "patch-manager"
  description = "Name to assign to resources in this module"
  type        = string
}

variable "tags" {
  description = "A map of tags to be added to associated resources"
  type        = map(string)

  default = {
    terraform_managed = "True"
  }
}

variable "max_scan_concurrency" {
  default     = 20
  description = "The maximum number of instances to operate on at once"
  type        = number
}

variable "max_scan_errors" {
  default     = 20
  description = "The maximum number of errors before stopping the install task scheduling"
  type        = number
}

variable "max_install_concurrency" {
  default     = 2
  description = "The maximum number of instances to operate on at once"
  type        = number
}

variable "max_install_errors" {
  default     = 2
  description = "The maximum number of errors before stopping the install task scheduling"
  type        = number
}

variable "platforms" {
  description = "The list of platforms you want to support"
  type        = set(string)

  default = [
    "AMAZON_LINUX_2",
    "AMAZON_LINUX",
    "CENTOS",
    "ORACLE_LINUX",
    "SUSE",
    "WINDOWS",
    "DEBIAN",
    "UBUNTU",
    "REDHAT_ENTERPRISE_LINUX",
    "MACOS"
  ]

  # Make sure that only supported platforms are passed in
  validation {
    error_message = "Please check that you are specifying only supported platforms."

    condition = (
      var.platforms == setintersection(
        var.platforms,
        [
          "AMAZON_LINUX_2",
          "AMAZON_LINUX",
          "CENTOS",
          "ORACLE_LINUX",
          "SUSE",
          "WINDOWS",
          "DEBIAN",
          "UBUNTU",
          "REDHAT_ENTERPRISE_LINUX",
          "MACOS"
        ]
      )
    )
  }
}

variable "log_bucket" {
  default     = null
  description = "S3 bucket that logs should be sent to"
  type        = string
}

variable "scan_cutoff" {
  default     = 1
  description = "How many hours before the end of the maintenance Window to stop scheduling new instances to scan"
  type        = number
}

variable "scan_duration" {
  default     = 4
  description = "How long in hours for the scan maintenance window"
  type        = number
}

variable "scan_log_prefix" {
  default     = "/patch_manager/scan/"
  description = "The S3 bucket subfolder to store scan logs in"
  type        = string
}

variable "scan_notification_configs" {
  default     = []
  description = "A set of objects containing `notification_config`s [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task#notification_config)"

  type = set(object({
    notification_arn    = string
    notification_events = string
    notification_type   = string
  }))

  validation {
    error_message = "Invalid value for `notification_events`."

    condition = (
      setunion(
        [
          for config in var.scan_notification_configs : config.notification_events
        ]
        ) == setintersection(
        [
          "All",
          "InProgress",
          "Success",
          "TimedOut",
          "Cancelled",
          "Failed"
        ],
        setunion(
          [
            for config in var.scan_notification_configs : config.notification_events
          ]
        )
      )
    )
  }

  validation {
    error_message = "Invalid `notification_type`."

    condition = (
      toset(
        [for config in var.scan_notification_configs : config.notification_type]
        ) == setintersection(
        [for config in var.scan_notification_configs : config.notification_type],
        [
          "Command",
          "Invocation"
        ]
      )
    )
  }
}

variable "scan_schedule" {
  description = "6-field Cron expression describing the maintenance schedule"
  type        = string
}

variable "schedule_timezone" {
  type        = string
  description = "IANA format timezone to use for Maintenance Window scheduling"
  default     = "UTC"

  validation {
    condition     = fileexists("/usr/share/zoneinfo.default/${var.schedule_timezone}") || fileexists("/usr/share/zoneinfo/${var.schedule_timezone}")
    error_message = "Time zone invalid or validation failed."
  }
}

variable "install_cutoff" {
  default     = 1
  description = "How many hours before the end of the maintenance Window to stop scheduling new instances to install patches"
  type        = number
}

variable "install_duration" {
  default     = 3
  description = "How long in hours for the install maintenance window"
  type        = number
}

variable "install_log_prefix" {
  default     = "/patch_manager/install/"
  description = "The S3 bucket subfolder to store install logs in"
  type        = string
}

variable "install_notification_configs" {
  default     = []
  description = "A set of objects containing `notification_config`s [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task#notification_config)"

  type = set(object({
    notification_arn    = string
    notification_events = string
    notification_type   = string
  }))

  validation {
    error_message = "Invalid value for `notification_events`."

    condition = (
      setunion(
        [
          for config in var.install_notification_configs : config.notification_events
        ]
        ) == setintersection(
        [
          "All",
          "InProgress",
          "Success",
          "TimedOut",
          "Cancelled",
          "Failed"
        ],
        setunion(
          [
            for config in var.install_notification_configs : config.notification_events
          ]
        )
      )
    )
  }

  validation {
    error_message = "Invalid `notification_type`."

    condition = (
      toset(
        [for config in var.install_notification_configs : config.notification_type]
        ) == setintersection(
        [for config in var.install_notification_configs : config.notification_type],
        [
          "Command",
          "Invocation"
        ]
      )
    )
  }
}

variable "install_schedule" {
  description = "6-field Cron expression describing the maintenance schedule"
  type        = string
}
