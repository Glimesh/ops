
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

