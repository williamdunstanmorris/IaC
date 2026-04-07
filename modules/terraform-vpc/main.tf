resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}




