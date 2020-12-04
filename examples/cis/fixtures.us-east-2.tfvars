region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"

create_sns_topic = true
create_iam_role  = true
force_destroy    = true

is_global_resource_region = true
is_logging_account       = true
cloudtrail_bucket_name   = "some-valid-bucket-name"
