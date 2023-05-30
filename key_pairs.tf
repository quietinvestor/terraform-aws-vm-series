# Key pairs are regional, so if you created them
# in one region, they aren't available in the other.
# Therefore, it is better to create them on the basis
# of the region where you deploy the VM-series firewall(s).
resource "aws_key_pair" "ssh" {
  key_name = "${local.user_project}key"
  # It is assumed that the SSH public key ssh-key.pub
  # is placed in the same directory as this file.
  public_key = file("ssh-key.pub")
}

# AWS CMK KMS key for VM-series firewall EBS root volume encryption
resource "aws_kms_key" "ebs-root" {
  # Reference:
  # https://docs.aws.amazon.com/kms/latest/developerguide/overview.html
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "AWS Customer Master Key (CMK) Key Management Service (KMS)"
  # The waiting period, specified in number of days.
  # After the waiting period ends, AWS KMS deletes the
  # KMS key. If you specify a value, it must be between
  # 7 and 30, inclusive.
  deletion_window_in_days = 30
  multi_region            = false
}

# Add an alias to the KMS key for easier reference
resource "aws_kms_alias" "ebs-root" {
  name          = "alias/${local.user_project}kms"
  target_key_id = aws_kms_key.ebs-root.key_id
}