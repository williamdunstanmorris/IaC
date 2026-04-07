resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}

data "aws_availability_zones" "azs" {}
data "aws_availability_zone" "available" {
  for_each = toset(data.aws_availability_zones.azs.names)
  name     = each.value
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = ""
}


