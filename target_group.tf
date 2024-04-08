# Define the VPC ID as a local variable for reusability
locals {
  vpc_id = data.aws_vpc.shared.id
}

# Create the GITLAB HTTP target group
resource "aws_lb_target_group" "gitlab_https" {
  name        = "GITLAB-HTTP"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = locals.vpc_id
}

# Attach the GITLAB HTTP target group to the specified target instance
resource "aws_lb_target_group_attachment" "gitlab_https" {
  target_group_arn = aws_lb_target_group.gitlab_https.arn
  target_id        = var.gitlab_instance_ip  # Use the variable to specify the target instance IP
}

# Create the VPN HTTPS target group
resource "aws_lb_target_group" "vpn_https" {
  name        = "VPN-HTTPS"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = locals.vpc_id
}

# Attach the VPN HTTPS target group to the specified VPN instance
resource "aws_lb_target_group_attachment" "vpn_https" {
  target_group_arn = aws_lb_target_group.vpn_https.arn
  target_id        = var.vpn_instance_ip
  depends_on       = [aws_lb_target_group.vpn_https]
}
