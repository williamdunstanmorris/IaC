locals {
  number_public_subnets = 2
}

resource "aws_subnet" "public" {
  count             = local.number_public_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 2, count.index + local.number_private_subnets)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Public ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_main_route_table_association" "public_traffic" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet" {
  count          = local.number_public_subnets
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}
