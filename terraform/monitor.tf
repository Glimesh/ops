resource "digitalocean_droplet" "monitor" {
  image              = "ubuntu-20-04-x64"
  name               = var.monitor_hostname
  region             = "nyc3"
  size               = "s-2vcpu-2gb"
  private_networking = true
  backups            = true

  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.digitalocean_priv_key_path)
    timeout     = "2m"
  }
}

resource "cloudflare_record" "monitor_record" {
    for_each = toset([
    "",
    "prometheus.",
    "grafana.",
    "loki.",
  ])

  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "A"
  name    = "${each.value}${var.monitor_hostname}"
  value   = digitalocean_droplet.monitor.ipv4_address
  proxied = false
}
