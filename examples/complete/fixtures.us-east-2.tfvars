region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"

create_sns_topic = true
create_iam_role  = true
force_destroy    = true

managed_rules = {
  mfa-enabled-for-iam-console-access = {
    description      = "Checks whether AWS Multi-Factor Authentication (MFA) is enabled for all AWS Identity and Access Management (IAM) users that use a console password. The rule is COMPLIANT if MFA is enabled.",
    identifier       = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS",
    input_parameters = {}
    tags = {
      "compliance/cis-aws-foundations/1.2": true
      "compliance/controls/aws-foundations-cis/1.2": "X.X"
    }
    enabled = true
  }
}
