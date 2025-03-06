resource "aws_apigatewayv2_api" "apigw-aws-redirect" {
  name          = "apigw-aws-redirect"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_domain_name" "apigw-aws-redirect-domain" {
  domain_name = "aws.joshbarbee.com"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.acm-cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_integration" "apigw-aws-redirect-integration" {
    api_id           = aws_apigatewayv2_api.apigw-aws-redirect.id
    integration_type = "HTTP_PROXY"
    integration_uri  = "https://d-9a67636455.awsapps.com/start/#/console?account_id=902448871458&role_name=SystemAdministrator"
}

resource "aws_apigatewayv2_route" "apigw-aws-redirect-route" {
    api_id    = aws_apigatewayv2_api.apigw-aws-redirect.id
    route_key = "GET /{proxy+}"
    target    = "integrations/${aws_apigatewayv2_integration.apigw-aws-redirect-integration.id}"
}

resource "aws_apigatewayv2_stage" "apigw-aws-redirect-stage" {
    api_id      = aws_apigatewayv2_api.apigw-aws-redirect.id
    name        = "$default"
    auto_deploy = true
}