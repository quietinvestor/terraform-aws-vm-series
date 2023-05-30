resource "aws_eip" "management" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  for_each          = local.firewall_settings
  network_interface = aws_network_interface.management[each.key].id

  tags = {
    Name = "${each.key}-eip-mgmt"
  }
}

resource "aws_eip" "untrust" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  for_each          = local.firewall_settings
  network_interface = aws_network_interface.untrust[each.key].id

  tags = {
    Name = "${each.key}-eip-untrust"
  }
}