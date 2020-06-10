/* vim: ts=2:sw=2:sts=0:expandtab */

##
# We default to not running in 'deploy' mode.  This can be overwritten on
# the CLI. E.g. terraform apply -var=deploy=true
variable "deploy" {
  default = false
}

# Provider for dev, qa, stage, prod
provider "aws" {
  version = "~> 2.40"
  region = "${module.shared.account["default_region"]}"

  assume_role {
    role_arn     = "arn:aws:iam::${module.shared.account["id"]}:role/${module.shared.account["role_name"]}"
    session_name = "${module.shared.account["session_name"]}"
    external_id  = "${module.shared.account["external_id"]}"
  }
}

# Provider for root
provider "aws" {
  alias = "root"
  version = "~> 2.40"
  region = "${module.shared.account["default_region"]}"

  assume_role {
    role_arn     = "arn:aws:iam::${lookup(module.shared.accounts["root"], "id")}:role/${module.shared.account["role_name"]}"
    session_name = "${module.shared.account["session_name"]}"
    external_id  = "${lookup(module.shared.accounts["root"], "external_id")}"
  }
}

##
# Credstash Provider
provider "credstash" {
  region  = "${module.shared.account["default_region"]}"
  profile = "terraform@${terraform.workspace}"
}

##
# Our shared infrastructure configs
module "shared" {
  source = "./modules/shared"
  deploy = "${var.deploy}"
}

##
# Common data sources for route53 domains.
# Public:  <env>.domain.com
# Private: <env>.internal.domain.com
data "aws_route53_zone" "public" {
  zone_id = "${module.shared.dns_zone_id["public"]}"
}
data "aws_route53_zone" "private" {
  zone_id = "${module.shared.dns_zone_id["private"]}"
}

data "aws_route53_zone" "domain" {
  provider = "aws.root"
  name = "domain.com"
}
