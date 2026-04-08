data "aws_availability_zones" "azs" {}
data "aws_availability_zone" "available" {
  for_each = toset(data.aws_availability_zones.azs.names)
  name     = each.value
}

data "aws_region" "current" {}
