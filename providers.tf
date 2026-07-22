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
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.2.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.2.0"
    }
  }
}

provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::417755753385:role/OrganizationRootAccessRole"
  }
  default_tags {
    tags = {
      Project = "Learning"
    }
  }
}

provider "google" {
  project = "project-2b40a90c-1a89-477e-894"
  region  = "europe-west3"
}

provider "argocd" {
  server_addr = "34.185.207.56:80"
  username    = "admin"
  password    = "198Kn7jD668F6nbN"
  insecure    = true
}
