locals {
  all_ipam_regions = toset([data.aws_region.current.name, "eu-west-3"])

  root_cidr = "10.0.0.0/12"
}

# Assisting in the creation of future VPCs, where necessary
resource "aws_vpc_ipam" "main" {
  cascade = true
  dynamic "operating_regions" {
    for_each = local.all_ipam_regions
    content {
      region_name = operating_regions.value
    }
  }
  tags = {
    Name = "Main"
  }
}

# Parent pool
resource "aws_vpc_ipam_pool" "root" {
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.main.private_default_scope_id
  cascade                           = true
  allocation_default_netmask_length = 16
  tags = {
    Name = "Root Pool"
  }
}

resource "aws_vpc_ipam_pool_cidr" "root" {
  ipam_pool_id = aws_vpc_ipam_pool.root.id
  cidr         = local.root_cidr
}

resource "aws_vpc_ipam_pool" "regional" {
  for_each            = local.all_ipam_regions
  address_family      = "ipv4"
  locale              = each.key
  ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.root.id
  tags = {
    Name = "${each.key}-region-pool"
  }
}





