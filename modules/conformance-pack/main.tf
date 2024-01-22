resource "aws_config_conformance_pack" "default" {
  name = module.this.name

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
  /*
  To access a public GitHub repo the following URL is used:
    https://raw.githubusercontent.com/<owner>/<repo>/<branch>/<path_to_file>
  
  To access a private GitHub repo an access token with appropriate permissions should be generated first and then provided in the url:
    https://<private_access_token>@raw.githubusercontent.com/<owner>/<repo>/<branch>/<path_to_file>
  */

  url = var.access_token == "" ? var.conformance_pack : "${split("://", var.conformance_pack)[0]}://${var.access_token}@${split("://", var.conformance_pack)[1]}"
}
