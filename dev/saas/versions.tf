terraform {
  required_version = ">= 0.15.5, <= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.55.0"
    }
  }

  backend "s3" {
    bucket = "devpie.io-terraform"
    key    = "dev/saas/terraform.tfstate"
    region = "eu-central-1"
  }
}
