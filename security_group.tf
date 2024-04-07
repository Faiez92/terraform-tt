resource "aws_security_group" "alb" {
  name        = "Private ALB - Security Group"
  description = "General rules for ALB Interconnexion"
  vpc_id      = data.aws_vpc.shared.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = [data.aws_vpc.shared.cidr_block]
    ipv6_cidr_blocks = ["xxxx:xxxx::/32"]
    description = "Configure outbound traffic"
  }

  tags = {
    Name = "Private ALB - Security Group"
  }
}
