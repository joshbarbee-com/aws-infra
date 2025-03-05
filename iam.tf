
resource "aws_iam_role" "github-cicd" {
    name = "github-cicd"
    assume_role_policy = data.aws_iam_policy_document.github-cicd-trust-policy.json
}

data "aws_iam_policy_document" "github-cicd-trust-policy" {
    statement {
      actions = [ "sts:AssumeRoleWithWebIdentity"]
      effect = "Allow"
      principals {
        type = "oidc-provider"
        identifiers = ["arn:aws:iam::902448871458:oidc-provider/token.actions.githubusercontent.com"]
      }
      condition {
        test = "StringEquals"
        variable = "token.actions.githubusercontent.com:sub"
        values = ["repo:joshbarbee/aws-infra:ref:refs/heads/main", "sts.amazonaws.com"]
      }
    }
}

data "aws_iam_policy_document" "terraform-infra-s3" {
    statement {
        sid = "ListBucket"
        effect = "Allow"
        actions = ["s3:ListBucket"]
        resources = ["arn:aws:s3:::josh-terraform-infra-state"]
    }

    statement {
        sid = "GetObject"
        effect = "Allow"
        actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        resources = ["arn:aws:s3:::josh-terraform-infra-state/*"]
    }
}

data "aws_iam_policy_document" "terraform-route53-hostedzone" {
    statement {
        sid = "Route53HostedZone"
        effect = "Allow"
        actions = [
            "route53:CreateHostedZone",
            "route53:UpdateHostedZoneComment",
            "route53:GetHostedZone",
            "route53:ListHostedZones",
            "route53:DeleteHostedZone",
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets",
            "route53:GetHostedZoneCount",
            "route53:ListHostedZonesByName"
        ]
        resources = [ aws_route53_zone.r53-hosted-zone.arn ]
    }
}

data "aws_iam_policy_document" "terraform-route53-records" {
    statement {
        sid = "Route53Records"
        effect = "Allow"
        actions = [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets",
            "route53:GetChange"
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
            "acm:DeleteCertificate"
        ]
        resources = [aws_acm_certificate_validation.acm-cert.arn]
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
            "iam:PassRole"
        ]
        resources = ["*"]
    }
}

resource "aws_iam_policy" "terraform-iam-roles" {
    name   = "terraform-iam-roles"
    policy = data.aws_iam_policy_document.terraform-iam-roles.json
}

resource "aws_iam_role_policy_attachment" "github-cicd-iam-roles-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-iam-roles.arn
}

resource "aws_iam_policy" "terraform-acm" {
    name   = "terraform-acm"
    policy = data.aws_iam_policy_document.terraform-acm.json
}

resource "aws_iam_policy" "terraform-route53-records" {
    name   = "terraform-route53-records"
    policy = data.aws_iam_policy_document.terraform-route53-records.json
}

resource "aws_iam_policy" "terraform-route53-hostedzone" {
    name   = "terraform-route53-hostedzone"
    policy = data.aws_iam_policy_document.terraform-route53-hostedzone.json
}

resource "aws_iam_policy" "terraform-infra-s3" {
    name   = "terraform-infra-s3"
    policy = data.aws_iam_policy_document.terraform-infra-s3.json
}

resource "aws_iam_role_policy_attachment" "github-cicd-infra-s3-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-infra-s3.arn
}

resource "aws_iam_role_policy_attachment" "github-cicd-route53-hostedzone-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-route53-hostedzone.arn
}

resource "aws_iam_role_policy_attachment" "github-cicd-route53-records-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-route53-records.arn
}

resource "aws_iam_role_policy_attachment" "github-cicd-acm-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-acm.arn
}