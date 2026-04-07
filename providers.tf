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