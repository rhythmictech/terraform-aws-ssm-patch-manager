# terraform-aws-ssm-patch-manager
Creates a basic SSM Patch Manager setup

[![tflint](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/rhythmictech/terraform-aws-ssm-patch-manager/actions/workflows/pre-commit.yaml)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Example
Here's what using the module will look like
```hcl
module "patch_manager" {
  source  = "rhythmictech/ssm-patch-manager/aws"
  version = "~> 1.0.0"

  log_bucket = var.log_bucket
  tags       = var.tags
}
```

## About
This module creates the needed resources to use the default Patch Baselines for any (or all) platforms supported by SSM Patch Manager.

### NOTE:
Patches will only be applied to instances tagged with `TAG_GROUP : $PLATFORM` where `$PLATFORM` is the name of the platform running on that instance.

### Supported Platforms:
- AMAZON_LINUX_2
- AMAZON_LINUX
- CENTOS
- ORACLE_LINUX
- SUSE
- WINDOWS
- DEBIAN
- UBUNTU
- REDHAT_ENTERPRISE_LINUX
- MACOS

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.28 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.53.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_maintenance_window.install](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window.scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window_target.install](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_target.scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_task.install](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_maintenance_window_task.scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_patch_group.patchgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_group) | resource |
| [aws_ssm_patch_baseline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_patch_baseline) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_install_cloudwatch_configs"></a> [install\_cloudwatch\_configs](#input\_install\_cloudwatch\_configs) | A set of objects containing `cloudwatch_config`s [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task#cloudwatch_config) | <pre>set(object({<br>    cloudwatch_log_group_name = string<br>    cloudwatch_output_enabled = bool<br>  }))</pre> | `[]` | no |
| <a name="input_install_cutoff"></a> [install\_cutoff](#input\_install\_cutoff) | How many hours before the end of the maintenance Window to stop scheduling new instances to install patches | `number` | `1` | no |
| <a name="input_install_duration"></a> [install\_duration](#input\_install\_duration) | How long in hours for the install maintenance window | `number` | `3` | no |
| <a name="input_install_log_prefix"></a> [install\_log\_prefix](#input\_install\_log\_prefix) | The S3 bucket subfolder to store install logs in | `string` | `"/patch_manager/install/"` | no |
| <a name="input_install_notification_configs"></a> [install\_notification\_configs](#input\_install\_notification\_configs) | A set of objects containing `notification_config`s [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task#notification_config) | <pre>set(object({<br>    notification_arn    = string<br>    notification_events = list(string)<br>    notification_type   = string<br>  }))</pre> | `[]` | no |
| <a name="input_install_notification_role_arn"></a> [install\_notification\_role\_arn](#input\_install\_notification\_role\_arn) | The role arn to use for notifications | `string` | `null` | no |
| <a name="input_install_schedule"></a> [install\_schedule](#input\_install\_schedule) | 6-field Cron expression describing the install maintenance schedule | `string` | n/a | yes |
| <a name="input_log_bucket"></a> [log\_bucket](#input\_log\_bucket) | S3 bucket that logs should be sent to | `string` | `null` | no |
| <a name="input_max_install_concurrency"></a> [max\_install\_concurrency](#input\_max\_install\_concurrency) | The maximum number of instances to operate on at once | `number` | `2` | no |
| <a name="input_max_install_errors"></a> [max\_install\_errors](#input\_max\_install\_errors) | The maximum number of errors before stopping the install task scheduling | `number` | `2` | no |
| <a name="input_max_scan_concurrency"></a> [max\_scan\_concurrency](#input\_max\_scan\_concurrency) | The maximum number of instances to operate on at once | `number` | `20` | no |
| <a name="input_max_scan_errors"></a> [max\_scan\_errors](#input\_max\_scan\_errors) | The maximum number of errors before stopping the install task scheduling | `number` | `20` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to assign to resources in this module | `string` | `"patch-manager"` | no |
| <a name="input_platforms"></a> [platforms](#input\_platforms) | The list of platforms you want to support | `set(string)` | <pre>[<br>  "AMAZON_LINUX_2",<br>  "AMAZON_LINUX",<br>  "CENTOS",<br>  "ORACLE_LINUX",<br>  "SUSE",<br>  "WINDOWS",<br>  "DEBIAN",<br>  "UBUNTU",<br>  "REDHAT_ENTERPRISE_LINUX",<br>  "MACOS"<br>]</pre> | no |
| <a name="input_scan_cloudwatch_configs"></a> [scan\_cloudwatch\_configs](#input\_scan\_cloudwatch\_configs) | A set of objects containing `cloudwatch_config`s [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task#cloudwatch_config) | <pre>set(object({<br>    cloudwatch_log_group_name = string<br>    cloudwatch_output_enabled = bool<br>  }))</pre> | `[]` | no |
| <a name="input_scan_cutoff"></a> [scan\_cutoff](#input\_scan\_cutoff) | How many hours before the end of the maintenance Window to stop scheduling new instances to scan | `number` | `1` | no |
| <a name="input_scan_duration"></a> [scan\_duration](#input\_scan\_duration) | How long in hours for the scan maintenance window | `number` | `4` | no |
| <a name="input_scan_log_prefix"></a> [scan\_log\_prefix](#input\_scan\_log\_prefix) | The S3 bucket subfolder to store scan logs in | `string` | `"/patch_manager/scan/"` | no |
| <a name="input_scan_notification_configs"></a> [scan\_notification\_configs](#input\_scan\_notification\_configs) | A set of objects containing `notification_config`s [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task#notification_config) | <pre>set(object({<br>    notification_arn    = string<br>    notification_events = list(string)<br>    notification_type   = string<br>  }))</pre> | `[]` | no |
| <a name="input_scan_notification_role_arn"></a> [scan\_notification\_role\_arn](#input\_scan\_notification\_role\_arn) | The role arn to use for notifications | `string` | `null` | no |
| <a name="input_scan_schedule"></a> [scan\_schedule](#input\_scan\_schedule) | 6-field Cron expression describing the scan maintenance schedule | `string` | n/a | yes |
| <a name="input_schedule_timezone"></a> [schedule\_timezone](#input\_schedule\_timezone) | IANA format timezone to use for Maintenance Window scheduling | `string` | `"UTC"` | no |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | The role that should be assumed when executing the task | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be added to associated resources | `map(string)` | <pre>{<br>  "terraform_managed": "True"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Getting Started
This workflow has a few prerequisites which are installed through the `./bin/install-x.sh` scripts and are linked below. The install script will also work on your local machine. 

- [pre-commit](https://pre-commit.com)
- [terraform](https://terraform.io)
- [tfenv](https://github.com/tfutils/tfenv)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [tfsec](https://github.com/tfsec/tfsec)
- [tflint](https://github.com/terraform-linters/tflint)

We use `tfenv` to manage `terraform` versions, so the version is defined in the `versions.tf` and `tfenv` installs the latest compliant version.
`pre-commit` is like a package manager for scripts that integrate with git hooks. We use them to run the rest of the tools before apply. 
`terraform-docs` creates the beautiful docs (above),  `tfsec` scans for security no-nos, `tflint` scans for best practices. 
