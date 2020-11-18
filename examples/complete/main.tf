provider "aws" {
  region = var.region
}

module "example" {
  source = "../.."

  create_sns_topic = var.create_sns_topic
  create_iam_role  = var.create_iam_role
  force_destroy    = var.force_destroy

  context = module.this.context
}
