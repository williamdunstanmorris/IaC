locals {
  number_private_subnets = 2
}

resource "aws_subnet" "private" {
  count             = local.number_private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Private ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_eip" "nat" {
  tags = {
    Name = "EIP Nat Gateway"
  }
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.private.*.id[0]
  allocation_id = aws_eip.nat.id
  tags = {
    Name = "Nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_association" {
  count          = local.number_private_subnets
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}