resource "aws_wafv2_web_acl_association" "default" {
  resource_arn = var.web_resource_arn
  web_acl_arn  = var.web_acl_arn
}
