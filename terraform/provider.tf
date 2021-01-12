terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.14.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.3.0"
    }
    uptimerobot = {
      source  = "louy/uptimerobot"
      version = "0.5.1"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "uptimerobot" {
  api_key = var.uptimerobot_api_key
}
