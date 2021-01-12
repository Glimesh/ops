
resource "digitalocean_tag" "web" {
  name = "web"
}

resource "digitalocean_vpc" "glimesh_public_vpc" {
  name   = "glimesh-public"
  region = "nyc3"
}

resource "digitalocean_database_cluster" "glimesh_primary_database" {
  name                 = "glimesh-primary-database"
  engine               = "pg"
  version              = "12"
  private_network_uuid = digitalocean_vpc.glimesh_public_vpc.id
  size                 = "db-s-2vcpu-4gb"
  region               = "nyc3"
  node_count           = 1
  tags                 = [digitalocean_tag.web.id]
  maintenance_window {
    day  = "monday"
    hour = "09:00:00"
  }
}

resource "digitalocean_database_firewall" "glimesh_primary_database_whitelist" {
  for_each   = toset(var.whitelisted_ips)
  cluster_id = digitalocean_database_cluster.glimesh_primary_database.id

  rule {
    type  = "ip_addr"
    value = each.value
  }
}

resource "digitalocean_database_firewall" "glimesh_primary_database_firewall" {
  cluster_id = digitalocean_database_cluster.glimesh_primary_database.id

  rule {
    type  = "tag"
    value = digitalocean_tag.web.id
  }
}

resource "digitalocean_database_user" "glimesh_db_user" {
  cluster_id = digitalocean_database_cluster.glimesh_primary_database.id
  name       = "glimesh"
}

resource "digitalocean_database_db" "glimesh_db" {
  cluster_id = digitalocean_database_cluster.glimesh_primary_database.id
  name       = "glimesh"
}

resource "digitalocean_droplet" "web" {
  count              = 2
  image              = "ubuntu-20-04-x64"
  name               = "do-nyc3-web${count.index + 1}.us-east.web.glimesh.tv"
  region             = "nyc3"
  size               = "c-2"
  private_networking = true
  vpc_uuid           = digitalocean_vpc.glimesh_public_vpc.id
  tags               = [digitalocean_tag.web.id]

  ssh_keys = var.digitalocean_web_ssh_keys
}

resource "cloudflare_record" "web_direct_record" {
  count   = 2
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = element(digitalocean_droplet.web.*.name, count.index)
  value   = element(digitalocean_droplet.web.*.ipv4_address, count.index)
  proxied = false
}


resource "digitalocean_loadbalancer" "glimesh_public_web_lb" {
  name                     = "glimesh-public-web-lb"
  region                   = "nyc3"
  vpc_uuid                 = digitalocean_vpc.glimesh_public_vpc.id
  enable_backend_keepalive = true

  sticky_sessions {
    type               = "cookies"
    cookie_name        = "_glimesh_lb"
    cookie_ttl_seconds = 3600
  }

  forwarding_rule {
    target_port     = 8080
    target_protocol = "http"

    entry_port     = 443
    entry_protocol = "https"

    certificate_name = "CloudFlareOrigin"
  }

  healthcheck {
    port     = 8080
    protocol = "tcp"
  }

  droplet_ids = digitalocean_droplet.web.*.id
}

resource "cloudflare_record" "web_record" {
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = "glimesh.tv"
  value   = digitalocean_loadbalancer.glimesh_public_web_lb.ip
  proxied = true
}
