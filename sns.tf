resource "aws_sns_topic" "global-alerts" {
    name = "global-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
    topic_arn = aws_sns_topic.alerts.arn
    protocol  = "email"
    endpoint  = var.email
}

resource "aws_sns_topic_subscription" "sms_alerts" {
    topic_arn = aws_sns_topic.alerts.arn
    protocol  = "sms"
    endpoint  = var.phone_number
}