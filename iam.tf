
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
        actions = ["s3:*"]
        resources = ["arn:aws:s3:::*"]
    }

    statement {
        sid = "GetObject"
        effect = "Allow"
        actions = ["s3:*"]
        resources = ["arn:aws:s3:::*/*"]
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
            "acm:*",
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

data "aws_iam_policy_document" "terraform-cloudwatch" {
    statement {
        sid = "CloudWatch"
        effect = "Allow"
        actions = [
            "cloudwatch:*",
        ]
        resources = ["*"]
    }
}

data "aws_iam_policy_document" "terraform-sns" {
    statement {
        sid = "SNS"
        effect = "Allow"
        actions = [
            "sns:*",
        ]
        resources = ["*"]
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

resource "aws_iam_policy" "terraform-sns" {
    name   = "terraform-sns"
    policy = data.aws_iam_policy_document.terraform-sns.json
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

resource "aws_iam_role_policy_attachment" "github-cicd-sns-attach" {
    role       = aws_iam_role.github-cicd.name
    policy_arn = aws_iam_policy.terraform-sns.arn
}

resource "aws_iam_role" "provisioner" {
    name = "${var.terraform_role_name}-provisioner"
    assume_role_policy = data.aws_iam_policy_document.provisioner-trust-policy.json
}

data "aws_iam_policy_document" "provisioner-trust-policy" {
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
        values = [
          for repo in jsondecode(file("./repos.json")) : "repo:${var.github_org}/${repo.repo_name}:ref:refs/heads/main"
        ]
      }
    }
}

data "aws_iam_policy_document" "provisioner-iam-roles" {
    statement {
        sid = "ProvisionerIAMRoles"
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

data "aws_iam_policy_document" "provisioner-s3" {
    statement {
        sid = "ProvisionerS3"
        effect = "Allow"
        actions = [
            "s3:*",
        ]
        resources = ["arn:aws:s3:::*"]
    }
}

resource "aws_iam_policy" "provisioner-iam-roles" {
    name   = "provisioner-iam-roles"
    policy = data.aws_iam_policy_document.provisioner-iam-roles.json
}

resource "aws_iam_policy" "provisioner-s3" {
    name   = "provisioner-s3"
    policy = data.aws_iam_policy_document.provisioner-s3.json
}
