# terraform-terraform-template
Template repository for terraform modules. Good for any cloud and any provider.

[![tflint](https://github.com/rhythmictech/terraform-terraform-template/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-terraform-template/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-terraform-template/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-terraform-template/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-terraform-template/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Example
Here's what using the module will look like
```hcl
module "example" {
  source = "rhythmictech/terraform-mycloud-mymodule
}
```

## About
A bit about this module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.5 |
| aws | >= 3.20 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.20 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| install\_schedule | 6-field Cron expression describing the maintenance schedule | `string` | n/a | yes |
| scan\_schedule | 6-field Cron expression describing the maintenance schedule | `string` | n/a | yes |
| install\_cutoff | How many hours before the end of the maintenance Window to stop scheduling new instances to install patches | `number` | `1` | no |
| install\_duration | How long in hours for the install maintenance window | `number` | `3` | no |
| install\_log\_prefix | The S3 bucket subfolder to store install logs in | `string` | `"/patch_manager/install/"` | no |
| log\_bucket | S3 bucket that logs should be sent to | `string` | `null` | no |
| max\_install\_concurrency | The maximum number of instances to operate on at once | `number` | `2` | no |
| max\_install\_errors | The maximum number of errors before stopping the install task scheduling | `number` | `2` | no |
| max\_scan\_concurrency | The maximum number of instances to operate on at once | `number` | `20` | no |
| max\_scan\_errors | The maximum number of errors before stopping the install task scheduling | `number` | `20` | no |
| name | Name to assign to resources in this module | `string` | `"patch-manager"` | no |
| platforms | The list of platforms you want to support | `set(string)` | <pre>[<br>  "AMAZON_LINUX_2",<br>  "AMAZON_LINUX",<br>  "CENTOS",<br>  "ORACLE_LINUX",<br>  "SUSE",<br>  "WINDOWS",<br>  "DEBIAN",<br>  "UBUNTU",<br>  "REDHAT_ENTERPRISE_LINUX",<br>  "MACOS"<br>]</pre> | no |
| scan\_cutoff | How many hours before the end of the maintenance Window to stop scheduling new instances to scan | `number` | `1` | no |
| scan\_duration | How long in hours for the scan maintenance window | `number` | `4` | no |
| scan\_log\_prefix | The S3 bucket subfolder to store scan logs in | `string` | `"/patch_manager/scan/"` | no |
| scan\_notification\_configs | A set of objects containing `notification_config`s [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task#notification_config) | <pre>set(object({<br>    notification_arn    = string<br>    notification_events = string<br>    notification_type   = string<br>  }))</pre> | `[]` | no |
| schedule\_timezone | IANA format timezone to use for Maintenance Window scheduling | `string` | `"UTC"` | no |
| tags | A map of tags to be added to associated resources | `map(string)` | <pre>{<br>  "terraform_managed": "True"<br>}</pre> | no |

## Outputs

No output.

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
