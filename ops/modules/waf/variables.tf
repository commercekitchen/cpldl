variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "web_acl_name" {
  description = "Name for the WAF WebACL"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "enable_shield" {
  description = "Enable AWS Shield Advanced for DDoS protection"
  type        = bool
  default     = false
}

variable "rate_limiter_threshold" {
  description = "Threshold for rate limiting requests per 5 minutes per IP"
  type        = number
  default     = 1000
}

variable "allowed_host_regex" {
  description = "Regex pattern of Host header values allowed to reach the app; anything else is blocked at the WAF before it hits the ALB (defense against Host header injection / password-reset-link poisoning). Matched inline via regex_match_statement rather than a regex_pattern_set, since the account is already at its NUM_REGEX_PATTERN_SETS_BY_ACCOUNT quota."
  type        = string
}

variable "waf_upload_bypass_path_regexes" {
  description = "List of regex strings for paths that should bypass body-size restrictions."
  type        = list(string)

  default = [
    "^/ckeditor/(?:pictures|attachment_files)(?:/|$)",

    "^/admin/courses(?:/|$)",
    "^/admin/courses/[^/]+(?:/|$)",
    "^/admin/courses/[^/]+/lessons(?:/|$)",
    "^/admin/courses/[^/]+/lessons/[^/]+(?:/|$)",

    "^/api/v1/admin/courses/[^/]+/lessons/[^/]+(?:/|$)",
    "^/api/v1/admin/courses/[^/]+/attachments(?:/|$)",
    "^/api/v1/admin/settings/(?:footer_logo|header_logo)(?:/|$)",

    "^/admin/cms_pages(?:/|$)",
    "^/admin/cms_pages/[^/]+(?:/|$)",
  ]
}
