resource "aws_api_gateway_account" "apigw-account" {
  cloudwatch_role_arn = aws_iam_role.apigw-cloudwatch-role.arn
}

resource "aws_apigatewayv2_api" "apigw-aws-redirect" {
  name          = "apigw-aws-redirect"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_domain_name" "apigw-aws-redirect-domain" {
  domain_name = aws_acm_certificate.acm-cert-aws.domain_name
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.acm-cert-aws.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_integration" "apigw-aws-redirect-integration" {
    api_id           = aws_apigatewayv2_api.apigw-aws-redirect.id
    integration_type = "HTTP_PROXY"
    integration_method = "GET"
    integration_uri  = var.sso_endpoint
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
    access_log_settings {
        destination_arn = aws_cloudwatch_log_group.apigw-aws-redirect-log-group.arn
        format          = jsonencode({
            requestId = "$context.requestId",
            ip        = "$context.identity.sourceIp",
            requestTime = "$context.requestTime",
            httpMethod = "$context.httpMethod",
            routeKey   = "$context.routeKey",
            status     = "$context.status",
            protocol   = "$context.protocol",
            responseLength = "$context.responseLength"
        })
    }
}