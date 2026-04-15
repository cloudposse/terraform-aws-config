# AWS Config Custom Rules Example

This example demonstrates how to use the new custom rules functionality in the terraform-aws-config module to support:

1. **Custom Lambda-based rules** - For evaluating AWS resources using custom Python/Node.js logic
2. **Custom Policy-based rules** - For evaluating resources using CFN Guard or other policy formats

## Features

- AWS-managed rules (existing functionality)
- Custom Lambda rules for complex compliance checks
- Custom policy-based rules using CFN Guard syntax
- Scope-based rule evaluation for specific resource types
- SNS notifications for compliance findings

## Prerequisites

Before using this example, you need:

1. An AWS account with appropriate permissions
2. Terraform >= 1.0
3. AWS CLI configured with credentials
4. (Optional) A Lambda function ARN for custom Lambda rules
5. (Optional) A CFN Guard policy file in S3 for custom policy rules

## How to Use

### 1. Custom Lambda Rules

Lambda-based rules allow you to implement custom compliance logic in Python or Node.js.

```hcl
custom_lambda_rules = {
  my_custom_rule = {
    description         = "Custom check for resource tagging"
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-config-rule"
    input_parameters = {
      requiredTags = "Environment,CostCenter"
    }
    scope = {
      compliance_resource_types = ["AWS::EC2::Instance"]
    }
    tags = {
      Type = "Custom"
    }
    enabled = true
  }
}
```

**Parameters:**
- `description`: Human-readable description of the rule
- `lambda_function_arn`: ARN of the Lambda function that evaluates the rule
- `input_parameters`: JSON parameters passed to the Lambda function
- `scope.compliance_resource_types`: Resource types to evaluate (optional)
- `tags`: Additional tags for the rule
- `enabled`: Set to true to activate the rule

**Lambda Function Requirements:**
- Must have a service role that allows AWS Config to invoke it
- Must return compliance status in the correct format
- See [AWS Config Custom Lambda Rules Documentation](https://docs.aws.amazon.com/config/latest/developerguide/custom-lambda-rules.html)

### 2. Custom Policy Rules

Policy-based rules evaluate resources against CFN Guard rules or other policy formats.

```hcl
custom_policy_rules = {
  cfn_guard_rule = {
    description = "CFN Guard rule for security compliance"
    policy = file("${path.module}/guard-rules/my-policy.guard")
    input_parameters = {
      check_name = "my_compliance_check"
    }
    scope = {
      compliance_resource_types = ["AWS::EC2::SecurityGroup"]
    }
    enabled = true
  }
}
```

**Parameters:**
- `description`: Human-readable description of the rule
- `policy`: Inline CFN Guard policy text
- `policy_arn`: S3 URI to a policy file (alternative to inline policy)
- `input_parameters`: Parameters for policy evaluation
- `scope.compliance_resource_types`: Resource types to evaluate (optional)
- `tags`: Additional tags for the rule
- `enabled`: Set to true to activate the rule

**CFN Guard Syntax Example:**
```cfn
rule sg_restricted_ingress {
  aws_security_group.SecurityGroupIngress[*] {
    cidr_ip != "0.0.0.0/0"
  }
}
```

See [AWS Config CFN Guard Documentation](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_develop-rules_cfn-guard.html)

## Deployment

```bash
cd examples/custom-rules

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Outputs

The example outputs:
- `aws_config_configuration_recorder_id`: ID of the Config recorder
- `custom_lambda_rule_arns`: ARNs of deployed Lambda rules
- `custom_policy_rule_arns`: ARNs of deployed policy rules
- `storage_bucket`: S3 bucket for Config data
- `sns_topic`: SNS topic for notifications

## Testing Custom Rules

Once deployed, you can test your rules:

```bash
# Check rule compliance status
aws configservice describe-compliance-by-config-rule

# Get detailed findings for a specific rule
aws configservice get-compliance-details-by-config-rule \
  --config-rule-name my_custom_rule
```

## Troubleshooting

### Rule shows "InsufficientData"
- Ensure AWS Config Recorder is running
- Check that target resources exist and match the scope
- Review Lambda function logs in CloudWatch

### Lambda function invocation errors
- Verify the Lambda function ARN is correct
- Check Lambda function permissions to be invoked by AWS Config
- Review Lambda function error logs in CloudWatch

### Policy evaluation errors
- Validate CFN Guard syntax using the `cfn-guard` CLI
- Check S3 policy file URI is accessible to AWS Config
- Review Config rule evaluation logs in CloudWatch

## Advanced Configuration

### Combining All Rule Types

```hcl
module "aws_config" {
  source = "../.."

  # AWS-managed rules
  managed_rules = {
    approved_amis_by_tag = {
      enabled    = true
      identifier = "APPROVED_AMIS_BY_TAG"
      # ... other properties
    }
  }

  # Custom Lambda rules
  custom_lambda_rules = {
    # ... Lambda-based rules
  }

  # Custom policy rules
  custom_policy_rules = {
    # ... Policy-based rules
  }

  # ... other configuration
}
```

### Per-Rule Tagging

Rules inherit module-level tags but can have additional rule-specific tags:

```hcl
custom_lambda_rules = {
  my_rule = {
    tags = {
      Environment = "prod"
      Team        = "security"
      Type        = "Custom"
    }
    # ... other properties
  }
}
```

### Disabling Rules

Set `enabled = false` to disable a rule without removing it from configuration:

```hcl
custom_lambda_rules = {
  deprecated_rule = {
    enabled = false
    # ... other properties
  }
}
```

## Related Documentation

- [AWS Config Custom Lambda Rules](https://docs.aws.amazon.com/config/latest/developerguide/custom-lambda-rules.html)
- [AWS Config CFN Guard Rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_develop-rules_cfn-guard.html)
- [AWS Config Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)
- [Terraform AWS Provider Config Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule)

## Support

For issues or questions, please refer to:
- [CloudPosse GitHub Issues](https://github.com/cloudposse/terraform-aws-config/issues)
- [AWS Config Documentation](https://docs.aws.amazon.com/config/)
