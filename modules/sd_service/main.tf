resource "aws_service_discovery_service" "default" {
  name = "${local.prefix}-sds"

  dns_config {
    namespace_id   = var.namespace_id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-sds"
  })
}