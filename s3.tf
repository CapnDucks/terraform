resource "aws_s3_bucket" "pna-s3" {
  bucket = "${terraform.workspace}-pna"
  acl    = "public-read"

  tags = {
    Name        = "PnA - Containerized"
    Environment = "${terraform.workspace}"
    Owner	= "${local.setting["owner"]}"
  }
}

resource "aws_s3_bucket_policy" "pna-s3" {
  bucket = "${terraform.workspace}-pna"

  policy = <<POLICY
{
   "Version": "2012-10-17",
   "Id": "PnABucketPolicy",
  "Statement": [
    {
      "Sid": "Stmt1571849930053",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.pna-s3.arn}/*",
      "Principal": "*"
    }
  ]
}
POLICY
}
