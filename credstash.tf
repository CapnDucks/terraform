module "credstash_role" {
    source                          = "./modules/iam_role"
    role_name                       = "CredstashRole"
    role_trust_principal_identifier = "ecs-tasks.amazonaws.com"
    role_description = "Used by WP Containers"
    policy_document = "${data.aws_iam_policy_document.credstash.json}"
}

data "aws_iam_policy_document" "credstash" {
  statement {
    actions = ["kms:Decrypt"]
    resources = ["*"]
  }

  statement {
    actions = [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
    ]
    resources = [
      "arn:aws:dynamodb:us-west-2:${module.shared.account["id"]}:table/credential-store"
    ]
  }

  statement {
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::mybucket-${terraform.workspace}/*",
      "arn:aws:s3:::mybucket-${terraform.workspace}"
    ]
  }
}
