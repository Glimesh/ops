variable "region" {}
variable "do_region" {}

variable "cloudflare_domain" {
    type = string
}

variable "ingest_size" {
  type = string
}
variable "ingest_count" {
  type = number
}

variable "edge_size" {
  type = string
}
variable "edge_count" {
  type = number
}

variable "ssh_keys" {
  type = list(string)
}

