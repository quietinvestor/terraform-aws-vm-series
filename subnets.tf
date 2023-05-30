resource "aws_subnet" "management" {
  vpc_id = aws_vpc.security.id

  for_each          = local.availability_zones
  availability_zone = each.value.az_name
  cidr_block        = each.value.sn_cidr_mgmt

  tags = {
    Name = "${local.user_project}sn-mgmt-${each.value.az_name}"
  }
}

resource "aws_subnet" "untrust" {
  vpc_id = aws_vpc.security.id

  for_each          = local.availability_zones
  availability_zone = each.value.az_name
  cidr_block        = each.value.sn_cidr_untrust

  tags = {
    Name = "${local.user_project}sn-untrust-${each.value.az_name}"
  }
}

resource "aws_subnet" "trust" {
  vpc_id = aws_vpc.security.id

  for_each          = local.availability_zones
  availability_zone = each.value.az_name
  cidr_block        = each.value.sn_cidr_trust

  tags = {
    Name = "${local.user_project}sn-trust-${each.value.az_name}"
  }
}