region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"

create_sns_topic                 = true
create_iam_role                  = true
global_resource_collector_region = "us-east-2"
force_destroy                    = true

managed_rules = {}

custom_lambda_rules = {}

custom_policy_rules = {}
