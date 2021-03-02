
terraform {
  required_version = " > 0.11" #  This is the terraform version   < 0.11 is used sometimes because of behavior change in 0.12
  required_providers {
    aws = "~> 2.0" # this is the provider version   means in the 2.x range
  }
}


provider "aws" {
  region = var.region
}

