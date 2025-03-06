resource "aws_acm_certificate" "acm-cert" {
    domain_name = "joshbarbee.com"
    validation_method = "DNS"
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_acm_certificate_validation" "acm-cert-validation" {
    certificate_arn = aws_acm_certificate.acm-cert.arn
    validation_record_fqdns = [for record in aws_route53_record.r53-cname-record-acm : record.fqdn]
}

resource "aws_route53_zone" "r53-hosted-zone" {
    name = "joshbarbee.com"
}

resource "aws_route53_record" "r53-ns-record" {
    zone_id = aws_route53_zone.r53-hosted-zone.zone_id
    name = "joshbarbee.com"
    type = "NS"
    ttl = 360
    records = [
        "ns-1002.awsdns-61.net.",
        "ns-251.awsdns-31.com.",
        "ns-1916.awsdns-47.co.uk.",
        "ns-1216.awsdns-24.org."
    ]
    allow_overwrite = true
}

resource "aws_route53_record" "r53-soa-record" {
    zone_id = aws_route53_record.r53-ns-record.zone_id
    name = "joshbarbee.com"
    type = "SOA"
    ttl = 900
    records = [ "ns-1002.awsdns-61.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400" ]
    allow_overwrite = true
}

resource "aws_route53_record" "r53-txt-record" {
    zone_id = aws_route53_record.r53-ns-record.zone_id
    name = "joshbarbee.com"
    type = "TXT"
    ttl = 300
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
    zone_id = aws_route53_zone.r53-hosted-zone.zone_id
}

resource "aws_route53_record" "r53-cname-record-dc" {
    zone_id = aws_route53_record.r53-ns-record.zone_id
    name = "_domainconnect.joshbarbee.com"
    type = "CNAME"
    ttl = 360
    records = [ "_domainconnect.gd.domaincontrol.com." ]
    allow_overwrite = true
}

resource "aws_route53_record" "r53-cname-record-www" {
    zone_id = aws_route53_record.r53-ns-record.zone_id
    name = "www.joshbarbee.com"
    type = "CNAME"
    ttl = 360
    records = [ "joshbarbee.com." ]
    allow_overwrite = true
}

resource "aws_route53_record" "r53-a-record-aws" {
    zone_id = aws_route53_record.r53-ns-record.zone_id
    name = aws_apigatewayv2_domain_name.apigw-aws-redirect-domain.domain_name
    type = "A"
    ttl = 300
    records = [ aws_apigatewayv2_domain_name.apigw-aws-redirect-domain.domain_name ]
 }