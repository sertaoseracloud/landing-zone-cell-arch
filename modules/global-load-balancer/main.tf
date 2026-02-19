resource "cloudflare_load_balancer_monitor" "global_health" {
  type           = "https"
  expected_codes = "200"
  method         = "GET"
  path           = "/healthz"
  interval       = 60
}

resource "cloudflare_load_balancer_pool" "pool_latam" {
  name    = "latam-supercell"
  monitor = cloudflare_load_balancer_monitor.global_health.id
  
  origins {
    name    = "aws-sa-east-1"
    address = var.aws_apigw_sa
    weight  = 0.5
  }
  origins {
    name    = "azure-brazilsouth"
    address = var.azure_apim_sa
    weight  = 0.5
  }
}

resource "cloudflare_load_balancer_pool" "pool_us" {
  name    = "us-supercell"
  monitor = cloudflare_load_balancer_monitor.global_health.id
  # (Origins omitidas para abreviar, segue a mesma lógica do pool latam)
}

resource "cloudflare_load_balancer" "global_lb" {
  zone_id          = "zone_id_da_cloudflare"
  name             = "api.empresa.com"
  fallback_pool_id = cloudflare_load_balancer_pool.pool_us.id
  default_pool_ids = [
    cloudflare_load_balancer_pool.pool_latam.id,
    cloudflare_load_balancer_pool.pool_us.id
  ]
  proxied          = true
  steering_policy  = "geo"

  region_pools {
    region   = "SAM"
    pool_ids = [cloudflare_load_balancer_pool.pool_latam.id, cloudflare_load_balancer_pool.pool_us.id]
  }
}