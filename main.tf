terraform {
    backend "s3" {
        bucket         = "terraform-infra-bucket"
        key            = "terraform.tfstate"
        region         = "us-east-2"
        use_lockfile = true
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
