locals {
  # User and project name prefix to apply to all resource Name tags
  user_project = "${var.username}-tf-${var.project_name}-"
}

locals {
  # Availability Zone (AZ) - Only one supported for the moment
  # NOTE: Duplicate variable with firewall_settings, but necessary
  # for subnets.tf, at least for the moment
  availability_zones = {
    # Management, untrust and trust subnets per AZ, auto-calculated
    # from VPC subnet, assuming it is a /16 and subnets should be /24
    for i in range(1, var.az_count + 1) : i => {
      az_name         = data.aws_availability_zones.list.names[i - 1]
      sn_cidr_mgmt    = cidrsubnet(var.vpc_cidr, 8, 0 + i)
      sn_cidr_untrust = cidrsubnet(var.vpc_cidr, 8, 10 + i)
      sn_cidr_trust   = cidrsubnet(var.vpc_cidr, 8, 20 + i)
    }
  }
}

locals {
  # Convert encrypt_root_volume user string input variable into boolean
  encrypt_root_volume = can(regex("^[Yy](?:[Ee][Ss])?$", var.encrypt_root_volume))
}

locals {
  # Map of firewall names as keys and corresponding index numbers
  # and variables as values, which in turn are also key-value pairs
  firewall_settings = {
    for i in range(1, var.firewall_count + 1) : "${local.user_project}${var.firewall_name}${i}" => {
      az_index           = i % var.az_count == 0 ? var.az_count : i % var.az_count
      availability_zone  = local.availability_zones[i % var.az_count == 0 ? var.az_count : i % var.az_count].az_name,
      bootstrap_options  = "type=dhcp-client;${local.management_interface_swap == true ? "op-command-modes=mgmt-interface-swap;" : ""}hostname=${local.user_project}${var.firewall_name}${i};authcodes=${var.authcode};${var.bootstrap_options}"
      index              = i,
      ip_private_mgmt    = cidrhost(local.availability_zones[i % var.az_count == 0 ? var.az_count : i % var.az_count].sn_cidr_mgmt, 10 + i),
      ip_private_untrust = cidrhost(local.availability_zones[i % var.az_count == 0 ? var.az_count : i % var.az_count].sn_cidr_untrust, 10 + i),
      ip_private_trust   = cidrhost(local.availability_zones[i % var.az_count == 0 ? var.az_count : i % var.az_count].sn_cidr_trust, 10 + i),
    }
  }
}

locals {
  # Merge firewall_settings map with new map, containing additional
  # key-value pairs, whose values are generated at runtime. Attempting
  # to include these in the original firewall_settings map throws a
  # circular reference error. 
  firewall_info = {
    for firewall, settings in local.firewall_settings : firewall => merge(settings, {
      ip_public_mgmt    = aws_eip.management[firewall].public_ip,
      ip_public_untrust = aws_eip.untrust[firewall].public_ip,
      url_mgmt          = aws_eip.management[firewall].public_dns,
      url_untrust       = aws_eip.untrust[firewall].public_dns,
    })
  }
}

locals {
  # Convert management_interface_swap user string input variable into boolean
  management_interface_swap = can(regex("^[Yy](?:[Ee][Ss])?$", var.management_interface_swap))
}