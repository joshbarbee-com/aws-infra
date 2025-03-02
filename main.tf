terraform {
    backend "s3" {
        bucket         = "josh-terraform-infra-state"
        key            = "terraform.tfstate"
        region         = "us-east-2"
        use_lockfile = true
    }
}

provider "aws" {
    region = "us-east-2"
}

