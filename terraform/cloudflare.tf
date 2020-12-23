data "cloudflare_zones" "glimesh_domain_zones" {
  filter {
    name   = var.cloudflare_domain
    status = "active"
  }
}

