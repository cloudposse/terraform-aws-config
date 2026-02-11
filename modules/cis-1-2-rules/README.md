# AWS Config Rules for CIS AWS Foundations Benchmark Compliance

This module outputs a map of [AWS Config](https://aws.amazon.com/config) Rules that should be in place as part of acheiving compliance with the [CIS AWS Foundation Benchmak 1.2](https://www.cisecurity.org/cis-benchmarks/#amazon_web_services) standard. These rules are meant to be used as an input to the [Cloud Posse AWS Config Module](../../) and are defined in the rules [catalog](../../catalog).

## Usage

### Which Account(s) Should Rules Be Applied In

In general, these rules are meant to be enabled in every region of each of your accounts, with some exceptions noted below.

### Controls You May Want to Disable

There are some controls that are part of the standard that should be disabled in certain scenarios.

#### CIS AWS Foundations Benchmark Control 2.7: Ensure CloudTrail logs are encrypted at rest using AWS KMS CMKs

When you are using a centralized CloudTrail account, you should only run this rule in the centralized account. The rule can be enabled in the centralized account by setting the `is_logging_account` variable to true and disabled in all other accounts by setting `is_logging_account` to false or omitting it as false is the default value.

#### CIS AWS Foundations Benchmark Controls 1.2-1.14, 1.16, 1.20, 1.22, and 2.5: Global Resources

These controls deal with ensuring various global resources, such as IAM Users, are configured in a way that aligns with the Benchmark. Since these resources are global, there is no reason to have AWS Config check them in each region. One region should be designated as the _Global Region_ for AWS Config and checks for these controls should only be run in that region. This set of checks can be enabled in the _Global Region_ by setting the `is_global_resource_region` to true and disabled in all other regions by setting `is_global_resource_region` to false or omitting it as false is the default value.

### Parameter Overrides

You may also override the values any of the AWS Config Parameters set by the rules from our [catalog](../../catalog) by providing a map of maps to the `parameter_overrides` variable. The example below shows overriding the `MaxPasswordAge` of the `iam-password-policy` rule. The rule defaults to 90 days, while in this example we want to set it to 45 days.

**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/cloudposse/terraform-aws-config/releases).

For a complete example, see [examples/cis](../../examples/cis).

For automated tests of the complete example using [bats](https://github.com/bats-core/bats-core) and [Terratest](https://github.com/gruntwork-io/terratest)
(which tests and deploys the example on AWS), see [test](test).

```hcl
module "cis_1_2_rules" {
  source = "cloudposse/config/aws//modules/cis-1-2-rules"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"


  is_global_resource_region = true
  is_logging_account       = true

  parameter_overrides = {
    "iam-password-policy": {
      "MaxPasswordAge": "45"
    }
  }
}

module "config" {
  source = "cloudposse/config/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  create_sns_topic = true
  create_iam_role  = true

  managed_rules = module.cis_1_2_rules.rules
  }
}
```



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_config_rules_yaml_config"></a> [aws\_config\_rules\_yaml\_config](#module\_aws\_config\_rules\_yaml\_config) | cloudposse/config/yaml | 1.0.2 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_cloudtrail_bucket_name"></a> [cloudtrail\_bucket\_name](#input\_cloudtrail\_bucket\_name) | The name of the S3 bucket where CloudTrail logs are being sent. This is needed to comply with 2.6 of the Benchmark<br/>which states:<br/><br/>Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket | `string` | n/a | yes |
| <a name="input_config_rules_paths"></a> [config\_rules\_paths](#input\_config\_rules\_paths) | Set of PATH'es to files with config rules | `set(string)` | <pre>[<br/>  "../../catalog/cloudtrail.yaml",<br/>  "../../catalog/cmk.yaml",<br/>  "../../catalog/iam.yaml",<br/>  "../../catalog/network.yaml",<br/>  "../../catalog/vpc.yaml"<br/>]</pre> | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_is_global_resource_region"></a> [is\_global\_resource\_region](#input\_is\_global\_resource\_region) | Flag to indicate if this instance of AWS Config is being installed to monitor global resources (such as IAM). In<br/>order to save money, you can disable the monitoring of global resources in all but region. If this flag is set to<br/>true, then the config rules associated with global resources in the catalog (globalResource: true) will be<br/>installed. If false, they will not be installed. | `bool` | `false` | no |
| <a name="input_is_logging_account"></a> [is\_logging\_account](#input\_is\_logging\_account) | Flag to indicate if this instance of AWS Config is being installed into a centralized logging account. If this flag<br/>is set to true, then the config rules associated with logging in the catalog (loggingAccountOnly: true) will be<br/>installed. If false, they will not be installed.<br/>installed. | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_parameter_overrides"></a> [parameter\_overrides](#input\_parameter\_overrides) | Map of parameters for interpolation within the YAML config templates<br/><br/>For example, to override the maxCredentialUsageAge parameter in the access-keys-rotated.yaml rule, you would specify<br/>the following:<br/><br/>parameter\_overrides = {<br/>  "access-keys-rotated" : { maxCredentialUsageAge : "120" }<br/>} | `map(map(string))` | `{}` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_support_policy_arn"></a> [support\_policy\_arn](#input\_support\_policy\_arn) | The ARN of the IAM Policy required for compliance with 1.20 of the Benchmark, which states:<br/><br/>Ensure a support role has been created to manage incidents with AWS Support<br/><br/>AWS provides a support center that can be used for incident notification and response, as well as technical support<br/>and customer services.<br/><br/>Create an IAM role to allow authorized users to manage incidents with AWS Support. By implementing least privilege<br/>for access control, an IAM role will require an appropriate IAM policy to allow support center access in order to<br/>manage incidents with AWS Support. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rules"></a> [rules](#output\_rules) | Enabled rules |
<!-- markdownlint-restore -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

