locals {
  imap_regions = toset([data.aws_region.current.name])
}

resource "aws_vpc_ipam" "main" {
  cascade = true
  dynamic "operating_regions" {
    for_each = local.imap_regions
    content {
      region_name = operating_regions.value
    }
  }
  tags = {
    Name = "Main"
  }
}

resource "aws_vpc_ipam_pool" "root" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id
  cascade        = true
  tags = {
    Name = "Root Pool"
  }
}

resource "aws_vpc_ipam_pool_cidr" "root" {
  ipam_pool_id = aws_vpc_ipam_pool.root.id
  cidr         = "10.0.0.0/12"
}

resource "aws_vpc_ipam_pool" "regional" {
  for_each            = local.imap_regions
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  locale              = each.value
  source_ipam_pool_id = aws_vpc_ipam_pool.root.id
  tags = {
    Name = "${each.value}-pool"
  }
}
