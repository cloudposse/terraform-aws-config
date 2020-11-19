region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"

create_sns_topic = true
create_iam_role  = true
force_destroy    = true

managed_rules = {
  account-part-of-organizations = {
    description      = "Checks whether AWS account is part of AWS Organizations. The rule is NON_COMPLIANT if an AWS account is not part of AWS Organizations or AWS Organizations master account ID does not match rule parameter MasterAccountId.",
    identifier       = "ACCOUNT_PART_OF_ORGANIZATIONS",
    trigger_type     = "PERIODIC"
    input_parameters = {}
    enabled          = true
  }
}
