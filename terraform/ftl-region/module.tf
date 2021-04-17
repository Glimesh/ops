
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.18.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.5.1"
    }
    uptimerobot = {
      source  = "louy/uptimerobot"
      version = "0.5.1"
    }
  }
}

data "cloudflare_zones" "glimesh_domain_zones" {
  filter {
    name   = var.cloudflare_domain
    status = "active"
  }
}

resource "digitalocean_tag" "ftl" {
  name = "ftl"
}

resource "digitalocean_tag" "ftl_edge" {
  name = "ftl-edge"
}

resource "digitalocean_tag" "ftl_ingest" {
  name = "ftl-ingest"
}


# Ingest
resource "digitalocean_droplet" "ftl_ingest" {
  count = var.ingest_count
  image = "ubuntu-20-04-x64"
  name = format("do-%s-ingest%d.%s.live.glimesh.tv", var.do_region, count.index + 1, var.region)
  region             = var.do_region
  size               = var.ingest_size
  private_networking = true
  tags               = [digitalocean_tag.ftl.id, digitalocean_tag.ftl_ingest.id]

  ssh_keys = var.ssh_keys

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.digitalocean_priv_key_path)
    timeout     = "2m"
  }
}

resource "uptimerobot_monitor" "ftl_ingest_monitor" {
  count         = var.ingest_count
  friendly_name = element(digitalocean_droplet.ftl_ingest.*.name, count.index)
  url           = element(digitalocean_droplet.ftl_ingest.*.ipv4_address, count.index)
  type          = "port"
  sub_type      = "custom"
  port          = "8084"
}

resource "cloudflare_record" "ftl_ingest_record" {
  count   = var.ingest_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = element(digitalocean_droplet.ftl_ingest.*.name, count.index)
  value   = element(digitalocean_droplet.ftl_ingest.*.ipv4_address, count.index)
  proxied = false
}

resource "cloudflare_record" "ftl_ingest_lb_record" {
  count   = var.ingest_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = "ingest.${var.region}.live.glimesh.tv"
  value   = element(digitalocean_droplet.ftl_ingest.*.ipv4_address, count.index)
  proxied = false
}


# Edge
resource "digitalocean_droplet" "ftl_edge" {
  count              = var.edge_count
  image              = "ubuntu-20-04-x64"
  name = format("do-%s-edge%d.%s.live.glimesh.tv", var.do_region, count.index + 1, var.region)
  region             = var.do_region
  size               = var.edge_size
  private_networking = true
  tags               = [digitalocean_tag.ftl.id, digitalocean_tag.ftl_edge.id]

  ssh_keys = var.ssh_keys

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.digitalocean_priv_key_path)
    timeout     = "2m"
  }
}

resource "uptimerobot_monitor" "ftl_edge_monitor" {
  count         = var.edge_count
  friendly_name = element(digitalocean_droplet.ftl_edge.*.name, count.index)
  url           = element(digitalocean_droplet.ftl_edge.*.ipv4_address, count.index)
  type          = "port"
  sub_type      = "custom"
  port          = "8084"
}

resource "cloudflare_record" "ftl_edge_record" {
  count   = var.edge_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = element(digitalocean_droplet.ftl_edge.*.name, count.index)
  value   = element(digitalocean_droplet.ftl_edge.*.ipv4_address, count.index)
  proxied = false
}

resource "cloudflare_record" "ftl_edge_lb_record" {
  count   = var.edge_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = "edge.${var.region}.live.glimesh.tv"
  value   = element(digitalocean_droplet.ftl_edge.*.ipv4_address, count.index)
  proxied = false
}



