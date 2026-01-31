#############################
# Regex pattern sets
#############################

resource "aws_wafv2_regex_pattern_set" "static_paths" {
  name        = "${var.project_name}-waf-static-paths-${var.environment_name}"
  scope       = "REGIONAL"
  description = "Static asset extensions"

  regular_expression { regex_string = "\\.(?:css|js|png|jpe?g|gif|ico|svg|webp|woff2?)$" }

  lifecycle {
    create_before_destroy = true
  }
}

# Narrow allowlist for paths where we disable ONLY the SizeRestrictions_BODY managed sub-rule
# (to permit multipart uploads / larger request bodies without bypassing the whole admin area).
resource "aws_wafv2_regex_pattern_set" "upload_bypass_paths" {
  name        = "${var.project_name}-waf-upload-bypass-paths-${var.environment_name}"
  scope       = "REGIONAL"
  description = "Paths that bypass CommonRuleSet SizeRestrictions_BODY only"

  dynamic "regular_expression" {
    for_each = var.waf_upload_bypass_path_regexes
    content {
      regex_string = regular_expression.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

#############################
# Web ACL
#############################

resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.project_name}-waf-${var.environment_name}"
  description = "WAF for Load Balancer"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  ########################################
  # 0) Block large cookies (cookie overflow attack)
  ########################################
  rule {
    name     = "BlockLargeCookie"
    priority = 0

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = 8192
        field_to_match {
          single_header {
            name = "cookie" # must be lowercase
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockLargeCookie"
      sampled_requests_enabled   = true
    }
  }

  ########################################
  # 1) Rate limiter
  ########################################
  rule {
    name     = "RateLimitIP"
    priority = 1

    statement {
      rate_based_statement {
        limit              = var.rate_limiter_threshold
        aggregate_key_type = "IP"
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitIP"
      sampled_requests_enabled   = true
    }
  }

  ########################################
  # 2) Anonymous IP List - AWS Managed Rules
  #    - Tor, proxies, VPNs
  ########################################
  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 2

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    override_action {
      // Don't block at first - this could affect libraries and legitimate VPN users
      count {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AnonymousIpListCount"
      sampled_requests_enabled   = true
    }
  }

  ########################################
  # 3) CommonRuleSet for allowlisted upload/form paths ONLY
  #    - Excludes only SizeRestrictions_BODY
  ########################################
  rule {
    name     = "CommonRuleSetUploadBypass"
    priority = 3

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {}
          }
        }

        scope_down_statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.upload_bypass_paths.arn
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetUploadBypass"
      sampled_requests_enabled   = true
    }
  }

  ########################################
  # 4) CommonRuleSet for everything else
  #    - Same protections as usual, INCLUDING SizeRestrictions_BODY
  #    - Excludes upload_bypass_paths and static assets
  ########################################
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 4

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        scope_down_statement {
          and_statement {

            # NOT (upload bypass paths) - handled by CommonRuleSetUploadBypass above
            statement {
              not_statement {
                statement {
                  regex_pattern_set_reference_statement {
                    arn = aws_wafv2_regex_pattern_set.upload_bypass_paths.arn
                    field_to_match {
                      uri_path {}
                    }
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }

            # NOT (static file extensions)
            statement {
              not_statement {
                statement {
                  regex_pattern_set_reference_statement {
                    arn = aws_wafv2_regex_pattern_set.static_paths.arn
                    field_to_match {
                      uri_path {}
                    }
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  ########################################
  # 5) KnownBadInputsRuleSet
  #    - Applied broadly, excluding static assets
  #    - (No admin-wide bypass)
  ########################################
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 5

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"

        scope_down_statement {
          not_statement {
            statement {
              regex_pattern_set_reference_statement {
                arn = aws_wafv2_regex_pattern_set.static_paths.arn

                field_to_match {
                  uri_path {}
                }

                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  ########################################
  # 6) SQLiRuleSet
  #    - Excludes multipart/form-data (your existing upload carve-out)
  #    - Excludes static assets
  #    - (No admin-wide bypass)
  ########################################
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 6

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"

        scope_down_statement {
          and_statement {

            # NOT (multipart/form-data) to allow data uploads
            statement {
              not_statement {
                statement {
                  byte_match_statement {
                    search_string = "multipart/form-data"

                    field_to_match {
                      single_header {
                        name = "content-type"
                      }
                    }

                    positional_constraint = "CONTAINS"

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }

            # NOT (static file extensions)
            statement {
              not_statement {
                statement {
                  regex_pattern_set_reference_statement {
                    arn = aws_wafv2_regex_pattern_set.static_paths.arn
                    field_to_match {
                      uri_path {}
                    }
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  ########################################
  # Web ACL visibility
  ########################################
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFWebACL"
    sampled_requests_enabled   = true
  }
}

#############################
# WAF Association with ALB
#############################

resource "aws_wafv2_web_acl_association" "waf_alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}

#############################
# Optional AWS Shield Advanced
#############################

resource "aws_shield_protection" "shield" {
  count        = var.enable_shield ? 1 : 0
  name         = "${var.web_acl_name}-shield"
  resource_arn = var.alb_arn
}

#############################
# Logging config
#############################

resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.project_name}-${var.environment_name}"
  retention_in_days = 14
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  resource_arn            = aws_wafv2_web_acl.waf.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]

  # Only keep what we care about
  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      # condition { action_condition { action = "ALLOW" } }
    }
  }

  redacted_fields {
    single_header { name = "authorization" }
  }

  depends_on = [aws_cloudwatch_log_group.waf]
}
