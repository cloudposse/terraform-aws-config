resource "aws_config_conformance_pack" "hipaa" {
  name = "operational-best-practices-for-HIPAA-Security"

  input_parameter {
    parameter_name  = "AccessKeysRotatedParamMaxAccessKeyAge"
    parameter_value = var.AccessKeysRotatedParamMaxAccessKeyAge
  }

  input_parameter {
    parameter_name  = "CloudwatchAlarmActionCheckParamInsufficientDataActionRequired"
    parameter_value = var.CloudwatchAlarmActionCheckParamInsufficientDataActionRequired
  }

  input_parameter {
    parameter_name  = "CloudwatchAlarmActionCheckParamOkActionRequired"
    parameter_value = var.CloudwatchAlarmActionCheckParamOkActionRequired
  }

  input_parameter {
    parameter_name  = "DynamodbThroughputLimitCheckParamAccountRCUThresholdPercentage"
    parameter_value = var.DynamodbThroughputLimitCheckParamAccountRCUThresholdPercentage
  }

  input_parameter {
    parameter_name  = "DynamodbThroughputLimitCheckParamAccountWCUThresholdPercentage"
    parameter_value = var.DynamodbThroughputLimitCheckParamAccountWCUThresholdPercentage
  }

  input_parameter {
    parameter_name  = "GuarddutyNonArchivedFindingsParamDaysHighSev"
    parameter_value = var.GuarddutyNonArchivedFindingsParamDaysHighSev
  }

  input_parameter {
    parameter_name  = "GuarddutyNonArchivedFindingsParamDaysLowSev"
    parameter_value = var.GuarddutyNonArchivedFindingsParamDaysLowSev
  }

  input_parameter {
    parameter_name  = "GuarddutyNonArchivedFindingsParamDaysMediumSev"
    parameter_value = var.GuarddutyNonArchivedFindingsParamDaysMediumSev
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamMaxPasswordAge"
    parameter_value = var.IamPasswordPolicyParamMaxPasswordAge
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamMinimumPasswordLength"
    parameter_value = var.IamPasswordPolicyParamMinimumPasswordLength
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamPasswordReusePrevention"
    parameter_value = var.IamPasswordPolicyParamPasswordReusePrevention
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireLowercaseCharacters"
    parameter_value = var.IamPasswordPolicyParamRequireLowercaseCharacters
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireNumbers"
    parameter_value = var.IamPasswordPolicyParamRequireNumbers
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireSymbols"
    parameter_value = var.IamPasswordPolicyParamRequireSymbols
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireUppercaseCharacters"
    parameter_value = var.IamPasswordPolicyParamRequireUppercaseCharacters
  }

  input_parameter {
    parameter_name  = "IamUserUnusedCredentialsCheckParamMaxCredentialUsageAge"
    parameter_value = var.IamUserUnusedCredentialsCheckParamMaxCredentialUsageAge
  }

  dynamic "input_parameter" {
    for_each = var.InternetGatewayAuthorizedVpcOnlyParamAuthorizedVpcIds != "" ? [1] : []
    content {
      parameter_name  = "InternetGatewayAuthorizedVpcOnlyParamAuthorizedVpcIds"
      parameter_value = var.InternetGatewayAuthorizedVpcOnlyParamAuthorizedVpcIds
    }
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort1"
    parameter_value = var.RestrictedIncomingTrafficParamBlockedPort1
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort2"
    parameter_value = var.RestrictedIncomingTrafficParamBlockedPort2
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort3"
    parameter_value = var.RestrictedIncomingTrafficParamBlockedPort3
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort4"
    parameter_value = var.RestrictedIncomingTrafficParamBlockedPort4
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort5"
    parameter_value = var.RestrictedIncomingTrafficParamBlockedPort5
  }

  input_parameter {
    parameter_name  = "S3AccountLevelPublicAccessBlocksParamBlockPublicAcls"
    parameter_value = var.S3AccountLevelPublicAccessBlocksParamBlockPublicAcls
  }

  input_parameter {
    parameter_name  = "S3AccountLevelPublicAccessBlocksParamBlockPublicPolicy"
    parameter_value = var.S3AccountLevelPublicAccessBlocksParamBlockPublicPolicy
  }

  input_parameter {
    parameter_name  = "S3AccountLevelPublicAccessBlocksParamIgnorePublicAcls"
    parameter_value = var.S3AccountLevelPublicAccessBlocksParamIgnorePublicAcls
  }

  input_parameter {
    parameter_name  = "S3AccountLevelPublicAccessBlocksParamRestrictPublicBuckets"
    parameter_value = var.S3AccountLevelPublicAccessBlocksParamRestrictPublicBuckets
  }

  template_body = local.template_body
}

data "http" "conformance_pack" {
  url = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-HIPAA-Security.yaml"
}

locals {
  template_body = data.http.conformance_pack.body
  //replace_true   = replace(local.template_body, "TRUE", "true")
  //final_template = replace(local.replace_true, "FALSE", "false")
}
