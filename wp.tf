module "wp" {
  source = "./modules/ecs-app"

  name    = "pna"
  cluster = "${module.shared.cluster}"

  image             = "${module.shared.cluster["ecr_repo"]}/planningandadvice:${local.image["planningandadvice"]}"
  port              = "80"

  launch_type = "${local.setting["launch_type"]}"
  cpus        = "${local.setting["cpus"]}"
  memory      = "${local.setting["memory"]}"

  enable_autoscaling    = true
  desired_count         = "${local.setting["ecs_desired_count"]}"
  autoscaling_min_count = "${local.setting["ecs_autoscaling_min_count"]}"
  autoscaling_max_count = "${local.setting["ecs_autoscaling_max_count"]}"
  autoscaling_scale_out_cooldown = 120

  cloudwatch_alarm_sns_topic = "${module.shared.sns["notifications"]}"

  container_volume_data = "/var/www/html/main/uploads"

  task_role_arn = "${module.credstash_role.role_arn}"

  lb_port     = "443"
  tg_protocol = "http"
  lb_protocol = "https"
  certificate = "${local.setting["ssl_arn"]}"

  public = "${local.setting["public"]}"

  health_check_path = "${local.setting["health_check_path"]}"
  health_check_success_codes = "${local.setting["health_codes"]}"

  idle_timeout = 120

  security_group_ids = "${list(module.sg.id)}"

  template = <<EOT2
[{
  "name": "$${name}",
  "image": "$${image}",
  "cpu": $${cpu},
  "memory": $${memory},
  "command": $${command},
  "essential": true,
  "portMappings": [
    {
      "hostPort": $${port},
      "containerPort": $${port},
      "protocol": "tcp"
    }
  ],
  "environment": [
    { "name": "APP_ENV",			"value": "${terraform.workspace}" },
    { "name": "WORDPRESS_AUTH_KEY",             "value": "${data.credstash_secret.wp-pna-auth-key.value}" },
    { "name": "WORDPRESS_AUTH_SALT",            "value": "${data.credstash_secret.wp-pna-auth-salt.value}" },
    { "name": "WORDPRESS_LOGGED_IN_KEY",        "value": "${data.credstash_secret.wp-pna-logged-in-key.value}" },
    { "name": "WORDPRESS_NONCE_KEY",            "value": "${data.credstash_secret.wp-pna-nonce-key.value}" },
    { "name": "WORDPRESS_NONCE_SALT",           "value": "${data.credstash_secret.wp-pna-nonce-salt.value}" },
    { "name": "WORDPRESS_SECURE_AUTH_KEY",      "value": "${data.credstash_secret.wp-pna-secure-auth-key.value}" },
    { "name": "WORDPRESS_SECURE_AUTH_SALT",     "value": "${data.credstash_secret.wp-pna-secure-auth-salt.value}" },
    { "name": "WORDPRESS_LOGGED_IN_SALT",       "value": "${data.credstash_secret.wp-pna-logged-in-salt.value}" },
    { "name": "WORDPRESS_DB_HOST",		"value": "${aws_db_instance.db.address}" },
    { "name": "WORDPRESS_DB_NAME",		"value": "${local.db["name"]}" },
    { "name": "WORDPRESS_DB_USER",		"value": "${local.db["user"]}" },
    { "name": "WORDPRESS_DB_PASSWORD",		"value": "${data.credstash_secret.wp-pna-db-pass.value}" },
    { "name": "WORDPRESS_DB_CHARSET",		"value": "utf8" },
    { "name": "WORDPRESS_DATE",			"value": "${timestamp()}" },
    { "name": "WORDPRESS_ENV",			"value": "${terraform.workspace}" },
    { "name": "WORDPRESS_TABLE_PREFIX",		"value": "${local.setting["table_prefix"]}" },
    { "name": "WORDPRESS_CONFIG_EXTRA", 	"value": "define( 'AS3CF_AWS_USE_EC2_IAM_ROLE', true );define( 'AS3CF_SETTINGS', serialize( array('provider' => 'aws','bucket' => '${terraform.workspace}-pna','region' => 'us-west-2','copy-to-s3' => true,'serve-from-s3' => true,'cloudfront' => '${local.setting["cloudfront"]}','domain' => '${local.setting["domain"]}','enable-object-prefix' => true,'object-prefix' => 'main/uploads/','use-yearmonth-folders' => true,'force-https' => false,'remove-local-file' => false,'object-versioning' => false,) ) );define( 'AS3CFPRO_LICENCE', '924650d6-9c01-4180-8207-2073962d6a6d' );define('WP_MEMORY_LIMIT','2048');define('AUTOSAVE_INTERVAL','120');define('WP_POST_REVISIONS','5');define('WP_CONTENT_FOLDERNAME','main');define('WP_CONTENT_DIR',dirname( __FILE__ ) . '\/main');define('WP_CONTENT_URL','/main');define( 'ADMIN_COOKIE_PATH', '/core/wp-admin/' );define( 'COOKIEPATH', '/' );define( 'SITECOOKIEPATH', '/' );$GLOBALS['environment'] = '${terraform.workspace}'; if (stripos($GLOBALS['environment'], 'dev') !== false && isset($_GET['debugIt'])) { ini_set('log_errors','On'); ini_set('display_errors', 'On'); ini_set('error_reporting', E_ALL ); define('WP_DEBUG', true); define('WP_DEBUG_LOG', true); define('WP_DEBUG_DISPLAY', true); if ($_GET['debugIt'] == 'php') { phpinfo(); } } else { define('WP_DEBUG', false);if (isset($_SERVER['HTTP_HOST']) && in_array($_SERVER['HTTP_HOST'], ['www.stage.domain.com','www.domain.com'])) {define('WP_HOME', 'https://' . $_SERVER['HTTP_HOST']);define('WP_SITEURL', 'https://' . $_SERVER['HTTP_HOST'] . '/core/');} else {define('WP_SITEURL', '${local.setting["wp_siteurl"]}');define('WP_HOME', '${local.setting["wp_home"]}');} } " }
  ],
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-create-group": "true",
      "awslogs-region": "$${region}",
      "awslogs-group": "$${family}",
      "awslogs-stream-prefix": "$${prefix}"
    }
  }
}]
EOT2
}
