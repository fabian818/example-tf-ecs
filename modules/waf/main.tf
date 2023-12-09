resource "aws_wafv2_web_acl" "default" {
  name        = "${local.prefix}-acl"
  description = "${local.prefix}-acl"
  scope       = var.scope

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.prefix}-rule-AWSManagedRulesAdminProtectionRuleSet-metric"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-2"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.prefix}-rule-AWSManagedRulesAmazonIpReputationList-metric"
      sampled_requests_enabled   = false
    }
  }



  rule {
    name     = "rule-3"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.prefix}-rule-AWSManagedRulesCommonRuleSet-metric"
      sampled_requests_enabled   = false
    }
  }



  rule {
    name     = "rule-4"
    priority = 4

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.prefix}-rule-AWSManagedRulesKnownBadInputsRuleSet-metric"
      sampled_requests_enabled   = false
    }
  }



  rule {
    name     = "rule-5"
    priority = 5

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.prefix}-rule-AWSManagedRulesLinuxRuleSet-metric"
      sampled_requests_enabled   = false
    }
  }


  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-acl"
  })

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${local.prefix}-metric"
    sampled_requests_enabled   = false
  }
}
