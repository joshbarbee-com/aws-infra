resource "aws_acm_certificate" "acm-cert" {
    domain_name       = var.domain_name
    validation_method = "DNS"
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_acm_certificate_validation" "acm-cert-validation" {
    certificate_arn          = aws_acm_certificate.acm-cert.arn
    validation_record_fqdns  = [for record in aws_route53_record.r53-cname-record-acm : record.fqdn]
}

resource "aws_route53_zone" "r53-hosted-zone" {
    name = var.domain_name
}

resource "aws_route53_record" "r53-txt-record" {
    zone_id = aws_route53_zone.r53-hosted-zone.zone_id
    name    = var.domain_name
    type    = "TXT"
    ttl     = 300
    records = [ "google-site-verification=lJ8vU8pelCEFGX_5hKoJL19iJ_N4EH3bJpLwo3CR594" ]
    allow_overwrite = true
}

resource "aws_route53_record" "r53-cname-record-acm" {
    for_each = {
        for dvo in aws_acm_certificate.acm-cert.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 360
    type            = each.value.type
    zone_id         = aws_route53_zone.r53-hosted-zone.zone_id
}

resource "aws_route53_record" "r53-cname-record-dc" {
    zone_id = aws_route53_zone.r53-hosted-zone.zone_id
    name    = "_domainconnect.${var.domain_name}"
    type    = "CNAME"
    ttl     = 360
    records = [ "_domainconnect.gd.domaincontrol.com." ]
    allow_overwrite = true
}

resource "aws_route53_record" "r53-cname-record-www" {
    zone_id = aws_route53_zone.r53-hosted-zone.zone_id
    name    = "www.${var.domain_name}"
    type    = "CNAME"
    ttl     = 360
    records = [ "${var.domain_name}." ]
    allow_overwrite = true
}
