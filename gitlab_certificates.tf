# Define local variables for better readability
locals {
  gitlab_domain_name = data.aws_route53_zone.gitlab.name
}

# Create ACM certificate resource
resource "aws_acm_certificate" "gitlab" {
  domain_name       = local.gitlab_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Create Route53 records for ACM certificate validation
resource "aws_route53_record" "gitlab_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.gitlab.domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.gitlab.zone_id
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  allow_overwrite = true
}

# Create ACM certificate validation resource
resource "aws_acm_certificate_validation" "gitlab" {
  certificate_arn         = aws_acm_certificate.gitlab.arn
  validation_record_fqdns = [
    for record in aws_route53_record.gitlab_certificate_validation : record.fqdn
  ]

  depends_on = [
    aws_route53_record.gitlab_certificate_validation,
  ]
}
