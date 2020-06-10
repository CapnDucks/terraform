/* vim: ts=2:sw=2:sts=0:expandtab */

# Note: changes to the backend require re-running 'terraform init'
terraform {
  required_version = "0.11.11"

  ##
  # WARNING!! Terraform prohibits variable interpolation when setting the
  # backend.  This means that you have to TRIPLE CHECK that the configured S3
  # backend bucket/key/encryption/etc 100% match the any config variables.
  # note: this is really only used during 'terraform init'
  backend "s3" {
    encrypt = true
    region  = "us-west-2"
    bucket  = "terraform-remotestate"
    key     = "wp-pna-tf/remote.tfstate"

    #ksm_key_id     = "alias/terraform"
    dynamodb_table = "terraform-statelock"
  }
}
