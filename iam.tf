
resource "aws_iam_role" "github-cicd" {
    name = var.terraform_role_name
    assume_role_policy = data.aws_iam_policy_document.github-cicd-trust-policy.json
}

data "aws_iam_policy_document" "github-cicd-trust-policy" {
    statement {
      actions = [ "sts:AssumeRoleWithWebIdentity"]
      effect = "Allow"
      principals {
        type = "Federated"
        identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"]
      }
      condition {
        test = "StringEquals"
        variable = "token.actions.githubusercontent.com:sub"
        values = ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
      }
    }
}

data "aws_iam_policy_document" "terraform-infra-s3" {
    statement {
        sid = "ListBucket"
        effect = "Allow"
        actions = ["s3:ListBucket"]
        resources = ["arn:aws:s3:::${var.state_bucket}"]
    }

    statement {
        sid = "GetObject"
        effect = "Allow"
        actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        resources = ["arn:aws:s3:::${var.state_bucket}/*"]
    }
}

data "aws_iam_policy_document" "terraform-route53" {
    statement {
        sid = "Route53"
        effect = "Allow"
        actions = [
            "route53:*",
            "route53domains:*"
        ]
        resources = [ aws_route53_zone.r53-hosted-zone.arn ]
    }
}

data "aws_iam_policy_document" "terraform-acm" {
    statement {
        sid = "ACMRequestCertificate"
        effect = "Allow"
        actions = [
            "acm:RequestCertificate",
            "acm:DescribeCertificate",
            "acm:ListCertificates",
            "acm:GetCertificate",
            "acm:DeleteCertificate",
            "acm:ListTagsForCertificate"
        ]
        resources = [aws_acm_certificate.acm-cert.arn]
    }
}

data "aws_iam_policy_document" "terraform-iam-roles" {
    statement {
        sid = "IAMRoles"
        effect = "Allow"
        actions = [
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:GetRole",
            "iam:ListRoles",
            "iam:UpdateRole",
            "iam:PassRole",
            "iam:CreatePolicy",
            "iam:DeletePolicy",
            "iam:GetPolicy",
            "iam:ListRolePolicies",
            "iam:UpdatePolicy",
            "iam:PassPolicy",
            "iam:GetPolicyVersion",
            "iam:ListAttachedRolePolicies",
            "iam:AttachRolePolicy",
            "iam:ListPolicyVersions"
        ]
        resources = ["*"]
    }
}

data "aws_iam_policy_document" "terraform-apigw" {
    statement {
        sid = "APIGateway"
        effect = "Allow"
        actions = [
            "apigateway:POST",
            "apigateway:GET",
            "apigateway:PUT",
            "apigateway:DELETE",
            "apigateway:PATCH",
        ]
        resources = [ "arn:aws:apigateway:${var.region}::/*" ]
    }
}

resource "aws_iam_policy" "terraform-iam-roles" {
    name   = "terraform-iam-roles"
    policy = data.aws_iam_policy_document.terraform-iam-roles.json
}

resource "aws_iam_policy" "terraform-acm" {
    name   = "terraform-acm"
    policy = data.aws_iam_policy_document.terraform-acm.json
}

resource "aws_iam_policy" "terraform-route53" {
    name   = "terraform-route53"
    policy = data.aws_iam_policy_document.terraform-route53.json
}

resource "aws_iam_policy" "terraform-infra-s3" {
    name   = "terraform-infra-s3"
    policy = data.aws_iam_policy_document.terraform-infra-s3.json
}

resource "aws_iam_policy" "terraform-apigw" {
    name   = "terraform-apigw"
    policy = data.aws_iam_policy_document.terraform-apigw.json
}

resource "aws_iam_role_policy_attachment" "github-cicd-iam-roles-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-iam-roles.arn
}

resource "aws_iam_role_policy_attachment" "github-cicd-infra-s3-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-infra-s3.arn
}

resource "aws_iam_role_policy_attachment" "github-cicd-route53-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-route53.arn
}

resource "aws_iam_role_policy_attachment" "github-cicd-acm-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-acm.arn
}

resource "aws_iam_role_policy_attachment" "github-cicd-apigw-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-apigw.arn
}

data "aws_iam_policy_document" "apigw-cloudwatchtrust-policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "apigw-cloudwatch-role" {
    name               = "apigw-cloudwatch-role"
    assume_role_policy = data.aws_iam_policy_document.apigw-cloudwatchtrust-policy.json
}

data "aws_iam_policy_document" "apigw-cloudwatch-policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "apigw-cloudwatch-policy" {
  name   = "apigw-cloudwatch-policy"
  policy = data.aws_iam_policy_document.apigw-cloudwatch-policy.json
}

resource "aws_iam_role_policy_attachment" "apigw-cloudwatch-attach" {
  role       = aws_iam_role.apigw-cloudwatch-role.name
  policy_arn = aws_iam_policy.apigw-cloudwatch-policy.arn
}

resource "aws_iam_role" "cloudwatch-sns-role" {
    name               = "cloudwatch-sns-role"
    assume_role_policy = data.aws_iam_policy_document.cloudwatch-sns-trust-policy.json
}

data "aws_iam_policy_document" "cloudwatch-sns-trust-policy" {
    statement {
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = ["cloudwatch.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "cloudwatch-sns-policy" {
    statement {
        effect = "Allow"

        actions = [
            "sns:Publish"
        ]

        resources = ["arn:aws:sns:${var.region}:${var.account_id}:${aws_sns_topic.alerts.name}"]
    }
}

resource "aws_iam_policy" "cloudwatch-sns-policy" {
    name   = "apigw-cloudwatch-sns-policy"
    policy = data.aws_iam_policy_document.cloudwatch-sns-policy.json
}

resource "aws_iam_role_policy_attachment" "apigw-cloudwatch-sns-attach" {
    role       = aws_iam_role.cloudwatch-sns-role.name
    policy_arn = aws_iam_policy.cloudwatch-sns-policy.arn
}