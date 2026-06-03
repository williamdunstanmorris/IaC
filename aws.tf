# module "network_frankfurt" {
#   source       = "./modules/aws-network"
# }
#
# module "eks" {
#   source = "./modules/aws-eks"
#   depends_on = [module.network_frankfurt]
# }