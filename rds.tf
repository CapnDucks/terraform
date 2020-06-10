resource "aws_db_subnet_group" "db" {
  name_prefix = "${lower(local.setting["app"])}db-"
  subnet_ids  = ["${split(",", module.shared.subnet_id["private"])}"]

  tags = "${local.tags}"
}

resource "aws_db_instance" "db" {
  identifier_prefix      = "${lower(local.setting["app"])}db-"
  allocated_storage      = "${local.db["allocated_storage"]}"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "${local.db["instance_class"]}"
  parameter_group_name   = "default.mysql8.0"
  deletion_protection    = "${terraform.workspace == "prod" ? true : false}"
  vpc_security_group_ids = ["${module.sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.db.id}"
  multi_az               = "${local.db["multi_az"]}"

  maintenance_window        = "wed:09:13-wed:09:43"
  backup_window             = "07:53-08:23"
  backup_retention_period   = "${local.db["backup_retention"]}"
  final_snapshot_identifier = "${lower(local.setting["app"])}db-snapshot-final"
  copy_tags_to_snapshot     = true

  name     = "${local.db["name"]}"
  username = "${local.db["user"]}"

  # Terraform needs to know this password directly in order to initialize the
  # RDS instance.
  password = "${data.credstash_secret.wp-pna-db-pass.value}"

  tags = "${local.tags}"
}
