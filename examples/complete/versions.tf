terraform {
  required_version = ">= 1.3"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 1.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}
