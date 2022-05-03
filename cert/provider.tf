terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}