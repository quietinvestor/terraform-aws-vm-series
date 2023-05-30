resource "aws_network_interface" "management" {
  description     = "Management Elastic Network Interface (ENI)"
  security_groups = [aws_security_group.management.id]
  subnet_id       = aws_subnet.management[each.value.az_index].id

  for_each    = local.firewall_settings
  private_ips = [each.value.ip_private_mgmt]

  tags = {
    Name = "${each.key}-eni-mgmt"
  }
}

resource "aws_network_interface" "untrust" {
  description       = "Untrust Elastic Network Interface (ENI)"
  security_groups   = [aws_security_group.untrust.id]
  source_dest_check = false
  subnet_id         = aws_subnet.untrust[each.value.az_index].id

  for_each    = local.firewall_settings
  private_ips = [each.value.ip_private_untrust]

  tags = {
    Name = "${each.key}-eni-untrust"
  }
}

resource "aws_network_interface" "trust" {
  description       = "Trust Elastic Network Interface (ENI)"
  security_groups   = [aws_security_group.trust.id]
  source_dest_check = false
  subnet_id         = aws_subnet.trust[each.value.az_index].id

  for_each    = local.firewall_settings
  private_ips = [each.value.ip_private_trust]

  tags = {
    Name = "${each.key}-eni-trust"
  }
}