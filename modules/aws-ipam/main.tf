# resource "aws_vpc" "main" {
#   ipv4_ipam_pool_id    = aws_vpc_ipam_pool.root.id
#   ipv4_netmask_length  = 16
#   enable_dns_hostnames = true
#   tags = {
#     Name = "Main"
#   }
# }
#
# # Main interface for allowing traffic into the VPC
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
# }