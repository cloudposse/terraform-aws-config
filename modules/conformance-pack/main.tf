resource "aws_config_conformance_pack" "hipaa" {
  name = "operational-best-practices-for-HIPAA-Security"

  dynamic "input_parameter" {
    for_each = var.parameter_overrides
    content {
      parameter_name  = input_parameter.key
      parameter_value = input_parameter.value
    }
  }

  template_body = data.http.conformance_pack.body
}

data "http" "conformance_pack" {
  url = var.conformance_pack
}
