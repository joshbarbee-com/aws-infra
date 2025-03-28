resource "aws_s3_bucket" "terraform_state" {
    for_each = { for repo in jsondecode(file("./repos.json")) : repo.repo_name => repo }

    bucket = "terraform-state-${each.key}"

    tags = {
        Name        = "terraform-state-${each.key}"
        Environment = var.environment
    }

    depends_on = [ aws_iam_policy.terraform-infra-s3 ]
}