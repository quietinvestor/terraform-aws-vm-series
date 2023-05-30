resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.security.id

  tags = {
    Name = "${local.user_project}igw"
  }
}