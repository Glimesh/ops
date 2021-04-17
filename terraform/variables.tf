
variable "ftl_orchestrator_hostname" {
  type = string
}

variable "monitor_hostname" {
  type = string
}

variable "whitelisted_ips" {
  type = list(string)
}

variable "digitalocean_token" {
  type = string
}

variable "digitalocean_live_ssh_keys" {
  type = list(string)
}

variable "digitalocean_web_ssh_keys" {
  type = list(string)
}

variable "digitalocean_key_name" {
  type = string
}

variable "digitalocean_priv_key_path" {
  type = string
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}

variable "cloudflare_domain" {
  type = string
}

variable "uptimerobot_api_key" {
  type = string
}

