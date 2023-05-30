output "ami-id" {
  value       = data.aws_ami.vm-series.id
  description = "Amazon Machine Image (AMI) ID"
}

output "panos-version" {
  # Confirm that PAN-OS version in AMI name matches that
  # input by user in var.panos_version. Sometimes, they
  # might not match if PAN-OS version is not available
  # for the selected AWS region.
  value       = regex("(?:9\\.1\\.[0-9][0-9]?(?:-h[1-9])?)|(?:10\\.[0-2]\\.[0-9][0-9]?(?:-h[1-9])?)", data.aws_ami.vm-series.name)
  description = "PAN-OS version"
}

output "firewall-info" {
  value = local.firewall_info
}