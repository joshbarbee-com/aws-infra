
## Connecting Terraform + Github CI/CD to AWS

This is all of the infrastructure used to manage architecture within
my AWS account, particularly IAM and networking. The idea behind this
repo is to manage all account infrastructure outside of AWS.

Unfortuantely, some steps must be done manually within the console
before this script is used. Three things must be done:

1. Create an S3 bucket to store the Terraform state file
    1. Create a bucket within AWS under any name.
    2. Use default settings when creating the bucket, but enable bucket versioning. Enable any other settings as needed by organizational requirements.

2. Create a temporary user in AWS to initially provision terraform locally.
    1. Attach the AdministratorAccess policy to the user
    2. Set your AWS profile with the access key and secret of the temporary user
    3. Run `terraform plan` and `terraform apply` locally. Do not worry about locally-generated lock files.
    4. Delete the temporary user once the apply is finished.
        
3. Update the Github workflow, by configuring  the `.github/workflows/push.yml` file
    1. Update the AWS region with the region you are deploying to
    2. Update the role with the name of the role you created in AWS

Note that from here, the created Terraform role must still be updated to have the ability to modify AWS resources as needed.

## Notes
Besides the manual steps above for connecting Terraform and Github CI/CD to AWS, you may also want to setup IAM Identity Center to configure SSO + MFA for user accounts. Unfortunately, this functionality cannot be scripted 
entirely in Terraform, and thus must be manually setup. This is not required if the root account is used for user access (not recommended).

This also means that management of all user / group policies cannot be done via this repo. For reference, in Identity Center, I have one user under a `dev` group which is given `SystemAdministrator` permissions. Feel free to adjust the permission set.