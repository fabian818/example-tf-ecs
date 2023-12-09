resource "aws_ssm_parameter" "output_pipeline" {
  for_each = local.ssm_parameters

  name  = "/dev/app/${each.key}"
  type  = "String"
  value = each.value
}