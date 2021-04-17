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

# # Default Region is NYC3 for us
provider "digitalocean" {
  token = var.digitalocean_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "uptimerobot" {
  api_key = var.uptimerobot_api_key
}

