resource "aws_vpc" "main" {
  ipv4_ipam_pool_id    = var.ipam_pool_id
  enable_dns_hostnames = true
  ipv4_netmask_length  = var.ipv4_netmark_length
  cidr_block           = "172.0.0.0/22"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Main"
  }
}