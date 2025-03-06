resource "aws_cloudwatch_log_group" "apigw-aws-redirect-log-group" {
  name              = "/aws/api-gateway/apigw-aws-redirect"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "apigw_4xx_errors" {
  alarm_name          = "API-Gateway-4XX-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  dimensions = {
    ApiId = aws_apigatewayv2_api.apigw-aws-redirect.id
  }

  alarm_description = "Alarm when API Gateway returns 4XX errors"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "apigw_5xx_errors" {
  alarm_name          = "API-Gateway-5XX-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  dimensions = {
    ApiId = aws_apigatewayv2_api.apigw-aws-redirect.id
  }

  alarm_description = "Alarm when API Gateway returns 5XX errors"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}