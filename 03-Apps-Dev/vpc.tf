locals {
  vpc_octet         = "0"
  vpc = {
    cidr               = "11.${local.vpc_octet}.0.0/16"
    azs                = ["us-east-1a", "us-east-1b"]
    private_subnets    = ["11.${local.vpc_octet}.1.0/24", "11.${local.vpc_octet}.2.0/24"]
    public_subnets     = ["11.${local.vpc_octet}.101.0/24", "11.${local.vpc_octet}.102.0/24"]
    single_nat_gateway = false
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "my-vpc"
  cidr               = local.vpc.cidr
  azs                = local.vpc.azs
  private_subnets    = local.vpc.private_subnets
  public_subnets     = local.vpc.public_subnets
  single_nat_gateway = local.vpc.single_nat_gateway

  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.product_tags, {
    Name = "my-vpc"
  })
}

module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "my-nat-instance"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "my-eip"
  }
}
