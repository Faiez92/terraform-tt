resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2017-08"
  certificate_arn   = aws_acm_certificate_validation.shared.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpn_https.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

### VPN
resource "aws_lb_listener_certificate" "vpn" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn   = aws_acm_certificate_validation.vpn.certificate_arn
}

resource "aws_lb_listener_rule" "vpn" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpn_https.arn
  }

  condition {
    host_header {
      values = ["${var.vpn_subdomain}${var.vpn_hosted_zone_name}"]
    }
  }
}

### GITLAB
resource "aws_lb_listener_certificate" "gitlab" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn   = aws_acm_certificate_validation.gitlab.certificate_arn
}

resource "aws_lb_listener_rule" "gitlab" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab_https.arn
  }

  condition {
    host_header {
      values = [var.gitlab_hosted_zone_name]
    }
  }
}
