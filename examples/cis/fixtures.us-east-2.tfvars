region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"

create_sns_topic                 = true
create_iam_role                  = true
global_resource_collector_region = "us-east-2"
force_destroy                    = true

is_logging_account     = true
cloudtrail_bucket_name = "some-valid-bucket-name"
