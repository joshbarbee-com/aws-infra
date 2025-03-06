variable "region" {
    description = "The AWS region"
    type        = string
    default     = "us-east-2"
}

variable "domain_name" {
    description = "The domain name for the application"
    type        = string
    default     = "joshbarbee.com"
}

variable "sso_endpoint" {
    description = "The SSO endpoint for the application"
    type        = string
    default     = "https://d-9a67636455.awsapps.com/start/#/console?account_id=902448871458&role_name=SystemAdministrator" 
}

variable "terraform_role_name" {
    description = "The name of the Terraform role"
    type        = string
    default     = "github-cicd" 
}

variable "account_id" {
    description = "The AWS account ID"
    type        = string
    default     = "902448871458"
}

variable "github_org" {
    description = "The GitHub organization"
    type        = string
    default     = "joshbarbee" 
}

variable "github_repo" {
    description = "The GitHub repository"
    type        = string
    default     = "aws-infra" 
}

variable "github_branch" {
    description = "The GitHub branch"
    type        = string
    default     = "main" 
}

variable "state_bucket" {
    description = "The S3 bucket for storing Terraform state"
    type        = string
    default     = "josh-terraform-infra-state" 
}

variable "email" {
    description = "The email address for alerts"
    type        = string
}

variable "phone_number" {
    description = "The phone number for alerts"
    type        = string
}