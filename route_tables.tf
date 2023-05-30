resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.security.default_route_table_id

  tags = {
    Name = "${local.user_project}rt-default"
  }
}

resource "aws_route_table" "management" {
  vpc_id = aws_vpc.security.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.user_project}rt-mgmt"
  }
}

resource "aws_route_table_association" "management" {
  for_each       = local.availability_zones
  subnet_id      = aws_subnet.management[each.key].id
  route_table_id = aws_route_table.management.id
}

resource "aws_route_table" "untrust" {
  vpc_id = aws_vpc.security.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.user_project}rt-untrust"
  }
}

resource "aws_route_table_association" "untrust" {
  for_each       = local.availability_zones
  subnet_id      = aws_subnet.untrust[each.key].id
  route_table_id = aws_route_table.untrust.id
}

resource "aws_route_table" "trust" {
  vpc_id = aws_vpc.security.id

  tags = {
    Name = "${local.user_project}rt-trust"
  }
}

resource "aws_route_table_association" "trust" {
  for_each       = local.availability_zones
  subnet_id      = aws_subnet.trust[each.key].id
  route_table_id = aws_route_table.trust.id
}