resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 1, 1)
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "" {
  vpc_id = ""
}

resource "aws_route" "" {
  route_table_id = ""
}