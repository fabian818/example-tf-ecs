resource "aws_ssm_parameter" "output_pipeline" {
  for_each = local.ssm_parameters

  name  = "/prod/app/${each.key}"
  type  = "String"
  value = each.value
}