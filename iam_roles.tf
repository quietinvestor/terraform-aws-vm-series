resource "aws_iam_role" "vm-monitor" {
  name = "${local.user_project}iam-role-vm-monitor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  # Reference:
  # https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-web-interface-help/device/device-vm-information-sources/settings-to-enable-vm-information-sources-for-aws-vpc
  inline_policy {
    name = "${local.user_project}iam-policy-vm-monitor"

    # Reference:
    # https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-aws/about-aws-vm-monitoring/set-up-vm-monitoring-on-aws#idd5be796f-b45f-4f4e-8b4b-8a0d7caa6f8a
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeTags",
            "ec2:DescribeInstances",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeSubnets"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = {
    Name = "${local.user_project}iam-role-vm-monitor"
  }
}

resource "aws_iam_instance_profile" "vm-monitor" {
  name = "${local.user_project}iam-instance-profile-vm-monitor"
  role = aws_iam_role.vm-monitor.name
}