locals {
  settings = {
    default = {
      app_env = "dev"
      owner = "wordpress"
      app = "pna"
      dbname  = "myDatabase"
      s3_origin_id_s3 = "s3origin"
      s3_origin_id_elb = "elborigin"
      ecs_desired_count = 1
      ecs_autoscaling_min_count = 1
      ecs_autoscaling_max_count = 1
      launch_type = "ec2"
      health_check_path = "/index.php"
      health_codes = "200,301,302"
      cpus = "512"
      memory = "1024"
      route53_hostname = "pna"
      public = false
      table_prefix = "mywpsite_"
      root_record_name = "${terraform.workspace}.domain.com"
      cloudfront = "www.${terraform.workspace}.domain.com"
      ssl_arn = ""
      wp_siteurl = "https://www.${terraform.workspace}.domain.com/core/"
      wp_home = "https://www.${terraform.workspace}.domain.com/"
    }

    prod  = {
      app_env = "prod"
      cloudfront = "www.domain.com"
      public = true
      launch_type = "fargate"
      ecs_desired_count = 4
      ecs_autoscaling_min_count = 4
      ecs_autoscaling_max_count = 8
      cpus = "2048"
      memory = "4096"
      hostname = "www"
      ssl_arn = ""
      wp_siteurl = "https://www.domain.com/core/"
      wp_home = "https://www.domain.com/"
    }

    stage = {
      app_env = "stage"
      public = true
      launch_type = "fargate"
      ecs_desired_count = 4
      ecs_autoscaling_min_count = 4
      ecs_autoscaling_max_count = 8
      cpus = "2048"
      memory = "4096"
      ssl_arn = ""
    }

    qa    = {
      app_env = "qa"
      ssl_arn = ""
      launch_type = "fargate"
      ecs_desired_count = 1
      ecs_autoscaling_min_count = 1
      ecs_autoscaling_max_count = 1
    }

    dev   = {
    }

  }

    setting = "${merge(local.settings["default"], local.settings[terraform.workspace])}"

  db_configs = {
    default = {
      name = "${local.setting["dbname"]}"
      instance_class = "db.t2.micro"
      allocated_storage = "10"
      multi_az = false
      user = "wpadmin"
      backup_retention = "7"
      password = "credstash:pna-db-pass"
    }

    prod = {
      multi_az = true
    }

    stage = {
       multi_az = true
    }

    qa    = {
    }

    dev = {
    }
  }

  db = "${merge(local.db_configs["default"], local.db_configs[terraform.workspace])}"

    tags = "${
    map(
      "Owner",  "${local.setting["owner"]}",
      "App",    "${local.setting["app"]}",
      "Env",    "${terraform.workspace}"
    )
  }"
}

##
# Variable delcarations for tracking ECS/AMI image versions for each account
variable "default_images" {
  default = {
    "planningandadvice" = "latest"
  }
}

variable "root_images" {
  default = {}
}

variable "prod_images" {
  default = {}
}

variable "stage_images" {
  default = {}
}

variable "qa_images" {
  default = {}
}

variable "dev_images" {
  default = {}
}

locals {
  images = {
    default = "${var.default_images}"
    root    = "${var.root_images}"
    prod    = "${var.prod_images}"
    stage   = "${var.stage_images}"
    qa      = "${var.qa_images}"
    dev     = "${var.dev_images}"
  }

  image = "${merge(local.images["default"], local.images[terraform.workspace])}"
}

# Using a merged map for this (similar to local.setting) breaks terraform
variable "public" {
  type = "map"
  default = {
    prod = true
    stage = true
    qa = false
    dev = false
  }
}
