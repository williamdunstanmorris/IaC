terraform {
  required_version = ">1.14.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    google = {
      source  = "hashicorp/google"
      version = "7.23.0"
    }
  }
}
