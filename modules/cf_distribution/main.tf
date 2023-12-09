data "aws_cloudfront_cache_policy" "default" {
  name = var.cache_policy_id
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "${local.prefix}-cf-OAC"
  description                       = "${local.prefix}-cf-OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "default" {
  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = "${local.prefix}-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }
  default_root_object = "index.html"
  enabled             = true

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.default.id
    target_origin_id       = "${local.prefix}-s3-origin"
    viewer_protocol_policy = "allow-all"
    response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
  }

  price_class = "PriceClass_All"

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-cf-distribution"
  })
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${var.bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.default.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = split(":", var.bucket_arn)[5]
  policy = data.aws_iam_policy_document.default.json
}