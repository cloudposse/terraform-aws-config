region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"

create_sns_topic                 = true
create_iam_role                  = true
global_resource_collector_region = "us-east-2"
force_destroy                    = true

managed_rules = {
  access-keys-rotated = {
    identifier  = "ACCESS_KEYS_ROTATED"
    description = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is NON_COMPLIANT if the access keys have not been rotated for more than maxAccessKeyAge number of days."
    input_parameters = {
      maxAccessKeyAge : "90"
    }
    enabled = true
    tags = {
      "compliance/cis-aws-foundations/1.2"                                 = true
      "compliance/cis-aws-foundations/filters/global-resource-region-only" = true
      "compliance/cis-aws-foundations/1.2/controls"                        = 1.4
    }
  }
}
