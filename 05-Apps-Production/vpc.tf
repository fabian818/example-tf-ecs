module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "${local.resource_prefix}-${local.aws_region}-vpc"
  cidr               = local.vpc.cidr
  azs                = local.vpc.azs
  private_subnets    = local.vpc.private_subnets
  public_subnets     = local.vpc.public_subnets
  single_nat_gateway = local.vpc.single_nat_gateway

  enable_dns_hostnames = true
  enable_nat_gateway   = false
  enable_vpn_gateway   = false

  tags = merge(local.product_tags, {
    Name = "${local.resource_prefix}-${local.aws_region}-vpc"
  })
}

module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "${local.resource_prefix}-${local.aws_region}-nat"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "${local.resource_prefix}-${local.aws_region}-nat-eip"
  }
}