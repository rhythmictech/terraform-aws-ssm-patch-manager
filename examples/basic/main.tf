module "patch_manager" {
  source  = "rhythmictech/ssm-patch-manager/aws"
  version = "~> 1.0.0"

  log_bucket = var.log_bucket
  tags       = var.tags
}
