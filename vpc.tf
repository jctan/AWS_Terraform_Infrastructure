module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.awsaccountname}-vpc"
  cidr = "17.1.0.0/25"

  azs              = ["${local.region}a", "${local.region}b"]
  public_subnets  = ["17.1.0.0/26", "17.1.0.64/26"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Tier = "Public"
  }
}