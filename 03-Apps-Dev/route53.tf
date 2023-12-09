module "app-records" {
  source   = "../modules/route53_record"
  for_each = local.records

  zone_id = local.zone_id
  dns     = each.value.dns
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
