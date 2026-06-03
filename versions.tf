terraform {
  required_version = "~> 1.15.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # s3 backend for maintaining terraform state for github actions
  backend "s3" {
    bucket = "minecraft-tf-state"
    key    = "minecraft/terraform.tfstate"
    region = "us-east-1"
  }
}