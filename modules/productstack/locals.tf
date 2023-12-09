locals {
  prefix = "${var.resource_prefix}-${var.aws_region}-${var.component_prefix}"

  ingress_relations = merge([
    for component_key, component in var.components : {
      for ingress_key, ingress in component.ingress :
      "${component_key}-${ingress.source}-${ingress.from}-${ingress.to}" => {
        target_component = component_key
        source           = ingress.source
        from             = ingress.from
        to               = ingress.to
        protocol         = ingress.protocol == null ? "tcp" : ingress.protocol
      }
    }
  ]...)

  egress_relations = merge([
    for component_key, component in var.components : {
      for egress_key, egress in component.egress :
      "${component_key}-${egress.source}-${egress.from}-${egress.to}" => {
        target_component = component_key
        source           = egress.source
        from             = egress.from
        to               = egress.to
        protocol         = egress.protocol == null ? "tcp" : egress.protocol
      }
    }
  ]...)
}
