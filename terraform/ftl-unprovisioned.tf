

resource "cloudflare_record" "ftl_region_record" {
  for_each = toset([
    "kjfk.live.glimesh.tv",
    "kord.live.glimesh.tv",
    "ksfo.live.glimesh.tv",
    "eham.live.glimesh.tv",
    "wsss.live.glimesh.tv",
    "egll.live.glimesh.tv",
    "eddf.live.glimesh.tv",
    "cyyz.live.glimesh.tv",
    "vobl.live.glimesh.tv"
  ])

  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "CNAME"
  name    = each.value
  value   = "edge.kjfk.live.glimesh.tv"
  proxied = false
}

resource "cloudflare_record" "ftl_region_edge_lb_record" {
  for_each = toset([
    "edge.kord.live.glimesh.tv",
    "edge.ksfo.live.glimesh.tv",
    "edge.eham.live.glimesh.tv",
    "edge.wsss.live.glimesh.tv",
    "edge.egll.live.glimesh.tv",
    "edge.eddf.live.glimesh.tv",
    "edge.cyyz.live.glimesh.tv",
    "edge.vobl.live.glimesh.tv"
  ])

  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "CNAME"
  name    = each.value
  value   = "edge.kjfk.live.glimesh.tv"
  proxied = false
}


resource "cloudflare_record" "ftl_region_ingest_lb_record" {
  for_each = toset([
    "ingest.kord.live.glimesh.tv",
    "ingest.ksfo.live.glimesh.tv",
    "ingest.eham.live.glimesh.tv",
    "ingest.wsss.live.glimesh.tv",
    "ingest.egll.live.glimesh.tv",
    "ingest.eddf.live.glimesh.tv",
    "ingest.cyyz.live.glimesh.tv",
    "ingest.vobl.live.glimesh.tv"
  ])

  zone_id = lookup(data.cloudflare_zones.glimesh_domain_zones.zones[0], "id")
  type    = "CNAME"
  name    = each.value
  value   = "ingest.kjfk.live.glimesh.tv"
  proxied = false
}

# Monitor these since they are hardcoded inside the OBS client
resource "uptimerobot_monitor" "ftl_region_ingest_lb_monitor" {
  for_each = toset([
    "ingest.kjfk.live.glimesh.tv",
    "ingest.kord.live.glimesh.tv",
    "ingest.ksfo.live.glimesh.tv",
    "ingest.eham.live.glimesh.tv",
    "ingest.wsss.live.glimesh.tv",
    "ingest.egll.live.glimesh.tv",
    "ingest.eddf.live.glimesh.tv",
    "ingest.cyyz.live.glimesh.tv",
    "ingest.vobl.live.glimesh.tv"
  ])

  friendly_name = each.value
  url           = each.value
  type          = "port"
  sub_type      = "custom"
  port          = "8084"
}
