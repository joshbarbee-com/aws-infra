terraform {
    backend "s3" {
        bucket         = "terraform-state-bucket"
        key            = "terraform.tfstate"
        region         = "us-east-2"
        dynamodb_table = "terraform_locks"
    }
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terraform-state" {
    bucket = "terraform-state-bucket"

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name           = "terraform_locks"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}
