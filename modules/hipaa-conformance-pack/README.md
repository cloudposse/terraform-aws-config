# AWS Config HIPAA Conformance Pack

This module deploys the [Operational Best Practices for HIPAA Security](https://docs.aws.amazon.com/config/latest/developerguide/operational-best-practices-for-hipaa_security.html) Conformance Pack. A conformance pack is a collection of AWS Config rules and remediation actions that can be easily deployed as a single entity in an account and a Region or across an organization in AWS Organizations.Conformance packs are created by authoring a YAML template that contains the list of AWS Config managed or custom rules and remediation actions.

The Conformance Pack cannot be deployed until AWS Config is deployed, which can be deployed using the [root module](../../) of this repository.

## Usage

**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/cloudposse/terraform-aws-config/releases).

For a complete example, see [examples/hipaa](../../examples/hipaa).

For automated tests of the complete example using [bats](https://github.com/bats-core/bats-core) and [Terratest](https://github.com/gruntwork-io/terratest)(which tests and deploys the example on AWS), see [test](test).

```hcl
module "hipaa_conformance_pack" {
  source = "https://github.com/cloudposse/terraform-aws-config.git//modules/hipaa-conformance-pack?ref=master"

  AccessKeysRotatedParamMaxAccessKeyAge = "45"

  depends_on = [
    module.config
  ]
}

module "config" {
  source = "https://github.com/cloudposse/terraform-aws-config.git?ref=master"

  create_sns_topic = true
  create_iam_role  = true
}
```
