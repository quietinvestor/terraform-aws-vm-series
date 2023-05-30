resource "aws_vpc" "security" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${local.user_project}vpc-security"
  }
}