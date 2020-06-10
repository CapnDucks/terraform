module "sg" {
  source = "./modules/sg"
  name   = "${local.setting["app"]}"
  tags   = "${local.tags}"
  self   = true
  vpc_id = "${module.shared.network["vpc_id"]}"

  ingress = "${
    map(
      "80",   "0.0.0.0/0",
      "443",  "0.0.0.0/0",
      "3306", join(",", list(module.shared.root["cidr_block"],
                             module.shared.network["cidr_block"],
                             module.shared.account["aws_corp_cidr_block"],
                             "10.200.0.0/16"))
    )
  }"
}
