variable "name" {
  type        = string
  description = "Name to assign to resources in this module"
  default     = "patch-manager"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to be added to associated resources"
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

variable "log_bucket" {
  default     = null
  description = "S3 bucket that logs should be sent to"
  type        = string
}

variable "scan_log_prefix" {
  type        = string
  description = "The S3 bucket subfolder to store scan logs in"
  default     = "/patch_manager/scan/"
}

variable "install_log_prefix" {
  type        = string
  description = "The S3 bucket subfolder to store install logs in"
  default     = "/patch_manager/install/"
}
