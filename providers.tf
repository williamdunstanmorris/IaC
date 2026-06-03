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
