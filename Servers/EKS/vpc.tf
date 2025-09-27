module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = local.name   
    cidr = local.vpc_cidr

    azs = local.azs

    private_subnets = local.private_subnets
    public_subnets = local.public_subnets

    enable_nat_gateway = true
    single_nat_gateway = true

    tags = {
        Name = local.name
        Environment = local.environment
    }

  
}