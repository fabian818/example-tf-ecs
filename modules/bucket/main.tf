resource "aws_s3_bucket" "default" {
  force_destroy = var.force_destroy

  bucket = "${local.prefix}-bucket"

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-bucket"
  })
}