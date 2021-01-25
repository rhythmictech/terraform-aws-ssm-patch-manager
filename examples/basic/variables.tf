variable "log_bucket" {
  default     = null
  description = "The name of an S3 bucket where logs should be stored"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources created by this module"
  type        = map(string)
}
