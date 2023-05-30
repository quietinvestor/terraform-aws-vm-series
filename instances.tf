resource "aws_instance" "vm-series" {
  ami                  = data.aws_ami.vm-series.id
  iam_instance_profile = aws_iam_instance_profile.vm-monitor.name
  instance_type        = var.instance_type
  key_name             = aws_key_pair.ssh.key_name

  for_each  = local.firewall_settings
  user_data = each.value.bootstrap_options

  network_interface {
    network_interface_id = aws_network_interface.management[each.key].id
    device_index         = local.management_interface_swap == true ? 1 : 0 // Due to management interface swap in bootstrap_options
  }

  network_interface {
    network_interface_id = aws_network_interface.untrust[each.key].id
    device_index         = local.management_interface_swap == true ? 0 : 1 // Due to management interface swap in bootstrap_options
  }

  network_interface {
    network_interface_id = aws_network_interface.trust[each.key].id
    device_index         = 2
  }

  # Encrypt VM-series firewall EBS root volume with AWS CMK KMS key
  root_block_device {
    encrypted  = local.encrypt_root_volume
    kms_key_id = aws_kms_key.ebs-root.key_id
  }

  tags = {
    Name = "${each.key}"
  }

  lifecycle {
    # Validate that AWS EC2 instance type submitted by user is valid.
    precondition {
      condition     = contains(data.aws_ec2_instance_types.list.instance_types, var.instance_type)
      error_message = "AWS EC2 instance type is not valid or not supported. Please visit the below link for a list of supported images:\n\nhttps://docs.paloaltonetworks.com/vm-series/10-2/vm-series-performance-capacity/vm-series-performance-capacity/vm-series-on-aws-models-and-instances"
    }
  }
}