resource "aws_security_group_rule" "ingress_sg" {
  for_each = {
    for index, relation in local.ingress_relations :
    index => relation
    if startswith(relation.source, "cidr-") == false
  }

  security_group_id        = aws_security_group.productstack_components[each.value.target_component].id
  type                     = "ingress"
  description              = "Ingress for ${each.value.target_component}"
  from_port                = each.value.from
  to_port                  = each.value.to
  protocol                 = each.value.protocol == null ? "tcp" : each.value.protocol
  source_security_group_id = aws_security_group.productstack_components[each.value.source].id
}

resource "aws_security_group_rule" "ingress_cidr" {
  for_each = {
    for index, relation in local.ingress_relations :
    index => relation
    if startswith(relation.source, "cidr-") == true
  }

  security_group_id = aws_security_group.productstack_components[each.value.target_component].id
  type              = "ingress"
  description       = "Ingress for ${each.value.target_component}"
  from_port         = each.value.from
  to_port           = each.value.to
  protocol          = each.value.protocol == null ? "tcp" : each.value.protocol
  cidr_blocks       = [element(split("-", each.value.source), 1)]
}

resource "aws_security_group_rule" "egress_sg" {
  for_each = {
    for index, relation in local.egress_relations :
    index => relation
    if startswith(relation.source, "cidr-") == false
  }

  security_group_id        = aws_security_group.productstack_components[each.value.target_component].id
  type                     = "egress"
  description              = "Egress for ${each.value.target_component}"
  from_port                = each.value.from
  to_port                  = each.value.to
  protocol                 = each.value.protocol == null ? "tcp" : each.value.protocol
  source_security_group_id = aws_security_group.productstack_components[each.value.source].id
}

resource "aws_security_group_rule" "egress_cidr" {
  for_each = {
    for index, relation in local.egress_relations :
    index => relation
    if startswith(relation.source, "cidr-") == true
  }

  security_group_id = aws_security_group.productstack_components[each.value.target_component].id
  type              = "egress"
  description       = "Egress for ${each.value.target_component}"
  from_port         = each.value.from
  to_port           = each.value.to
  protocol          = each.value.protocol == null ? "tcp" : each.value.protocol
  cidr_blocks       = [element(split("-", each.value.source), 1)]
}
