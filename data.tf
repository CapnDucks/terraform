data "aws_route53_zone" "service" {
  zone_id = "${module.shared.dns_zone_id["service"]}"
}

data "aws_route53_zone" "domain" {
  zone_id = "${module.shared.dns_zone_id["public"]}"
}

data "credstash_secret" "wp-pna-auth-key" {
  name = "wp-pna-auth-key"
}

data "credstash_secret" "wp-pna-auth-salt" {
  name = "wp-pna-auth-salt"
}

data "credstash_secret" "wp-pna-logged-in-key" {
  name = "wp-pna-logged-in-key"
}

data "credstash_secret" "wp-pna-logged-in-salt" {
  name = "wp-pna-logged-in-salt"
}

data "credstash_secret" "wp-pna-nonce-key" {
  name = "wp-pna-nonce-key"
}

data "credstash_secret" "wp-pna-nonce-salt" {
  name = "wp-pna-nonce-salt"
}

data "credstash_secret" "wp-pna-secure-auth-key" {
  name = "wp-pna-secure-auth-key"
}

data "credstash_secret" "wp-pna-secure-auth-salt" {
  name = "wp-pna-secure-auth-salt"
}

data "credstash_secret" "wp-pna-db-pass" {
  name = "wp-pna-db-pass"
}
