data "digitalocean_ssh_key" "terraform" {
  name = var.digitalocean_key_name
}

resource "digitalocean_tag" "ftl" {
  name = "ftl"
}

# Orchestrator
resource "digitalocean_droplet" "ftl_orchestrator" {
  image              = "ubuntu-20-04-x64"
  name               = var.ftl_orchestrator_hostname
  region             = "nyc3"
  size               = "c-4"
  private_networking = true
  tags               = [digitalocean_tag.ftl.id]

  ssh_keys = var.digitalocean_live_ssh_keys

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.digitalocean_priv_key_path)
    timeout     = "2m"
  }
}
resource "uptimerobot_monitor" "ftl_orchestrator_monitor" {
  friendly_name = var.ftl_orchestrator_hostname
  url           = digitalocean_droplet.ftl_orchestrator.ipv4_address
  type          = "port"
  sub_type      = "custom"
  port          = "8085"
}

resource "cloudflare_record" "ftl_orchestrator_lb_record" {
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = var.ftl_orchestrator_hostname
  value   = digitalocean_droplet.ftl_orchestrator.ipv4_address
  proxied = false
}

# Ingest
resource "digitalocean_droplet" "ftl_ingest" {
  count              = var.ftl_ingest_count
  image              = "ubuntu-20-04-x64"
  name               = "do-nyc3-ingest${count.index + 1}.kjfk.live.glimesh.tv"
  region             = "nyc3"
  size               = "c-2"
  private_networking = true
  tags               = [digitalocean_tag.ftl.id]

  ssh_keys = var.digitalocean_live_ssh_keys

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.digitalocean_priv_key_path)
    timeout     = "2m"
  }
}

resource "uptimerobot_monitor" "ftl_ingest_monitor" {
  count         = var.ftl_ingest_count
  friendly_name = element(digitalocean_droplet.ftl_ingest.*.name, count.index)
  url           = element(digitalocean_droplet.ftl_ingest.*.ipv4_address, count.index)
  type          = "port"
  sub_type      = "custom"
  port          = "8084"
}

resource "cloudflare_record" "ftl_ingest_record" {
  count   = var.ftl_ingest_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = element(digitalocean_droplet.ftl_ingest.*.name, count.index)
  value   = element(digitalocean_droplet.ftl_ingest.*.ipv4_address, count.index)
  proxied = false
}

resource "cloudflare_record" "ftl_ingest_lb_record" {
  count   = var.ftl_ingest_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = "ingest.kjfk.live.glimesh.tv"
  value   = element(digitalocean_droplet.ftl_ingest.*.ipv4_address, count.index)
  proxied = false
}


# Edge
resource "digitalocean_droplet" "ftl_edge" {
  count              = var.ftl_edge_count
  image              = "ubuntu-20-04-x64"
  name               = "do-nyc3-edge${count.index + 1}.kjfk.live.glimesh.tv"
  region             = "nyc3"
  size               = "c-8"
  private_networking = true
  tags               = [digitalocean_tag.ftl.id]

  ssh_keys = var.digitalocean_live_ssh_keys

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.digitalocean_priv_key_path)
    timeout     = "2m"
  }
}

resource "uptimerobot_monitor" "ftl_edge_monitor" {
  count         = var.ftl_edge_count
  friendly_name = element(digitalocean_droplet.ftl_edge.*.name, count.index)
  url           = element(digitalocean_droplet.ftl_edge.*.ipv4_address, count.index)
  type          = "port"
  sub_type      = "custom"
  port          = "8084"
}

resource "cloudflare_record" "ftl_edge_record" {
  count   = var.ftl_edge_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = element(digitalocean_droplet.ftl_edge.*.name, count.index)
  value   = element(digitalocean_droplet.ftl_edge.*.ipv4_address, count.index)
  proxied = false
}

resource "cloudflare_record" "ftl_edge_lb_record" {
  count   = var.ftl_edge_count
  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = "edge.kjfk.live.glimesh.tv"
  value   = element(digitalocean_droplet.ftl_edge.*.ipv4_address, count.index)
  proxied = false
}


