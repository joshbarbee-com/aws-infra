
## Connecting Terraform + Github CI/CD to AWS

This is all of the infrastructure used to manage architecture within
my AWS account, particularly IAM and networking. The idea behind this
repo is to manage all account infrastructure outside of AWS.

Unfortuantely, some steps must be done manually within the console
before this script is used. Three things must be done:

1. Create an S3 bucket to store the Terraform state file
    1. Create a bucket within AWS under any name.
    2. Use default settings when creating the bucket, but enable bucket versioning. Enable any other settings as needed by organizational requirements.

2. Github is allowed to interact with AWS via OIDC.
    1. Within IAM, navigate to Identity Providers
    2. Add a new provider using OpenID Connect
        - The provider value should be `token.actions.githubusercontent.com`
        - The provider audience should be `sts.amazonaws.com`
    3. Create a new role for CICD within IAM
        - Use a custom trust policy, such as the below, making sure to replace anyything in `{*****}`:
            ```
            {
                "Version": "2012-10-17",
                "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Federated": "arn:aws:iam::{account_id}:oidc-provider/token.actions.githubusercontent.com"
                    },
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                        "StringEquals": {
                            "token.actions.githubusercontent.com:sub": "repo:{github_org}/{github_repo}:ref:refs/heads/{github_branch}",
                            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                        }
                    }
                }
                ]
            }
            ```
            This only grants the ability to assume the role to the OIDC Github CICD credential. The role uses temporary credentials for the length of the session, so risk of credential leakage is mitigated.
    4. Finish creating the role. We will attach a policy, so do not add any now.
    5. Create a new policy with the following information:
        ```
        {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "ListBucket",
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::{bucket_name}"
                ]
            },
            {
                "Sid": "GetObject",
                "Effect": "Allow",
                "Action": [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::{bucket_name}/*"
                ]
            }
        ]
        }
        ```
        This grants the Terraform execution role the ability to list objects in the S3 state bucket, as well as read, write, and delete those objects. This policy only allows access to the bucket that you created in step 1. Additional granular access can be configured for each of the `terraform.tfstate` and any lock files terraform generates, however, only Terraform should ever be reading / writing to this bucket, so it may be not worth the time, since the security is already sufficient.
3. Update the Github workflow, by configuring  the `.github/workflows/push.yml` file
    1. Update the AWS region with the region you are deploying to
    2. Update the role with the name of the role you created in AWS

Note that from here, the created Terraform role must still be updated to have the ability to modify AWS resources as needed.