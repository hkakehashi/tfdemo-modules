terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 1.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
