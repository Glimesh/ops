# Computer Name	Human Name	DigitalOcean DC’s	Notes
# kjfk.live.glimesh.tv	North America - New York	NYC1, NYC2, NYC3	
# kord.live.glimesh.tv	North America - Chicago	n/a	Points to KJFK
# ksfo.live.glimesh.tv	North America - San Francisco	SFO1, SFO2, SFO3	Points to KJFK
# eham.live.glimesh.tv	Europe - Amsterdam, Netherlands	AMS1, AMS2	Points to KJFK
# wsss.live.glimesh.tv	Asia - Singapore	SGP1	Points to KJFK
# egll.live.glimesh.tv	Europe - London, United Kingdom	LON1	Points to KJFK
# eddf.live.glimesh.tv	Europe - Frankfurt, Germany	FRA1	Points to KJFK
# cyyz.live.glimesh.tv	North America - Toronto, Canada	TOR1	Points to KJFK
# vobl.live.glimesh.tv	Asia - Bangalore, India	BLR1	Points to KJFK

resource "digitalocean_tag" "ftl" {
  name = "ftl"
}

data "digitalocean_ssh_key" "terraform" {
  name = var.digitalocean_key_name
}


locals {
  regions = {
    eddf = {
      region       = "eddf",
      do_region    = "fra1",
      ingest_count = 1,
      edge_count   = 1,
      edge_size    = "s-2vcpu-4gb"
    },
    egll = {
      region       = "egll",
      do_region    = "lon1",
      ingest_count = 1,
      edge_count   = 2,
      edge_size    = "s-2vcpu-4gb"
    },
    eham = {
      region       = "eham",
      do_region    = "ams3",
      ingest_count = 1,
      edge_count   = 1,
      edge_size    = "c-2"
    },
    kjfk = {
      region       = "kjfk",
      do_region    = "nyc3",
      ingest_count = 1,
      edge_count   = 6,
      edge_size    = "s-2vcpu-4gb"
    },
    ksfo = {
      region       = "ksfo",
      do_region    = "sfo3",
      ingest_count = 1,
      edge_count   = 1,
      edge_size    = "s-2vcpu-4gb"
    },
    wsss = {
      region       = "wsss",
      do_region    = "sgp1",
      ingest_count = 1,
      edge_count   = 1,
      edge_size    = "s-2vcpu-4gb"
    },
    # vobl points to wsss
    vobl = {
      region       = "vobl",
      do_region    = "blr1",
      ingest_count = 0,
      edge_count   = 0,
      edge_size    = "c-2"
    },
    # cyyz points to kjfk
    cyyz = {
      region       = "cyyz",
      do_region    = "tor1",
      ingest_count = 0,
      edge_count   = 0,
      edge_size    = "c-2"
    },
  }
}


module "ftl-region" {
  source   = "./ftl-region"
  for_each = local.regions

  region    = each.value.region
  do_region = each.value.do_region

  ingest_count = each.value.ingest_count
  ingest_size  = "c-4"
  edge_count   = each.value.edge_count
  edge_size    = each.value.edge_size

  ssh_keys          = var.digitalocean_live_ssh_keys
  cloudflare_domain = var.cloudflare_domain
}

