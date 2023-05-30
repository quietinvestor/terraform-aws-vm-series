resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.security.id

  ingress {
    protocol    = "icmp"
    self        = true
    from_port   = -1
    to_port     = -1
    description = "Allow inbound ping traffic within security group"
  }

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 22
    to_port     = 22
    description = "Allow inbound SSH traffic within security group"
  }

  ingress {
    protocol    = "icmp"
    cidr_blocks = var.my_ip_list
    from_port   = -1
    to_port     = -1
    description = "Allow inbound ping traffic from my IP"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.my_ip_list
    from_port   = 22
    to_port     = 22
    description = "Allow inbound SSH traffic from my IP"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.my_ip_list
    from_port   = 443
    to_port     = 443
    description = "Allow inbound HTTPS traffic from my IP"
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "${local.user_project}sg-default"
  }
}

resource "aws_security_group" "management" {
  name        = "${local.user_project}sg-mgmt"
  description = "Management network interface security group"
  vpc_id      = aws_vpc.security.id

  ingress {
    protocol    = "icmp"
    self        = true
    from_port   = -1
    to_port     = -1
    description = "Allow inbound ping traffic within security group"
  }

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 22
    to_port     = 22
    description = "Allow inbound SSH traffic within security group"
  }

  ingress {
    protocol    = "icmp"
    cidr_blocks = var.my_ip_list
    from_port   = -1
    to_port     = -1
    description = "Allow inbound ping traffic from my IP"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.my_ip_list
    from_port   = 22
    to_port     = 22
    description = "Allow inbound SSH traffic from my IP"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.my_ip_list
    from_port   = 443
    to_port     = 443
    description = "Allow inbound HTTPS traffic from my IP"
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "${local.user_project}sg-mgmt"
  }
}

resource "aws_security_group" "untrust" {
  name        = "${local.user_project}sg-untrust"
  description = "Untrust network interface security group"
  vpc_id      = aws_vpc.security.id

  ingress {
    protocol    = "icmp"
    self        = true
    from_port   = -1
    to_port     = -1
    description = "Allow inbound ping traffic within security group"
  }

  ingress {
    protocol    = "icmp"
    cidr_blocks = var.my_ip_list
    from_port   = -1
    to_port     = -1
    description = "Allow inbound ping traffic from my IP"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.my_ip_list
    from_port   = 22
    to_port     = 22
    description = "Allow inbound SSH traffic from my IP"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.my_ip_list
    from_port   = 80
    to_port     = 80
    description = "Allow inbound HTTP traffic from my IP"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.my_ip_list
    from_port   = 443
    to_port     = 443
    description = "Allow inbound HTTPS traffic from my IP"
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "${local.user_project}sg-untrust"
  }
}

resource "aws_security_group" "trust" {
  name        = "${local.user_project}sg-trust"
  description = "trust network interface security group"
  vpc_id      = aws_vpc.security.id

  ingress {
    protocol    = "icmp"
    self        = true
    from_port   = -1
    to_port     = -1
    description = "Allow inbound ping traffic within security group"
  }

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 443
    to_port     = 443
    description = "Allow inbound HTTPS traffic within security group"
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "${local.user_project}sg-trust"
  }
}