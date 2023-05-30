resource "aws_vpc_dhcp_options" "default" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "${local.user_project}dhcp-default"
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp-association" {
  vpc_id          = aws_vpc.security.id
  dhcp_options_id = aws_vpc_dhcp_options.default.id
}