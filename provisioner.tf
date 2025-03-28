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
          for repo in jsondecode(file("./repos.json")) : "repo:${var.github_org}/${repo.repo_name}:ref:refs/heads/*"
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

resource "aws_iam_policy" "provisioner-iam-roles" {
    name   = "provisioner-iam-roles"
    policy = data.aws_iam_policy_document.provisioner-iam-roles.json
}