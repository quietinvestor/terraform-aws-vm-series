# PA-VM AMI ID lookup based on version and license type (determined by product code)
data "aws_ami" "vm-series" {
  most_recent = true
  owners      = ["aws-marketplace"]

  # Reference:
  # https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-aws/deploy-the-vm-series-firewall-on-aws/obtain-the-ami/get-amazon-machine-image-ids
  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.panos_version}*"]
  }
  filter {
    name   = "product-code"
    values = [var.license_product_code]
  }
}

# List all availability zones for a given AWS region
data "aws_availability_zones" "list" {
  all_availability_zones = true

  filter {
    name   = "region-name"
    values = [var.region]
  }

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# List all supported AWS EC2 instance types
data "aws_ec2_instance_types" "list" {
  # Reference:
  # https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-performance-capacity/vm-series-performance-capacity/vm-series-on-aws-models-and-instances
  filter {
    name = "instance-type"
    values = [
      "m4.xlarge",
      "m4.2xlarge",
      "m4.4xlarge",
      "m5.large",
      "m5.xlarge",
      "m5.2xlarge",
      "m5.4xlarge",
      "m5.12xlarge",
      "m5n.large",
      "m5n.xlarge",
      "m5n.2xlarge",
      "m5n.4xlarge",
      "c4.large",
      "c4.xlarge",
      "c4.2xlarge",
      "c4.4xlarge",
      "c4.8xlarge",
      "c5.large",
      "c5.xlarge",
      "c5.2xlarge",
      "c5.4xlarge",
      "c5.9xlarge",
      "c5.18xlarge",
      "c5n.large",
      "c5n.xlarge",
      "c5n.2xlarge",
      "c5n.4xlarge",
      "c5n.9xlarge",
      "c5n.18xlarge",
      "r5.2xlarge"
    ]
  }
}