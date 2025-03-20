output "waf_arn" {
  description = "The ARN of the created WAF WebACL"
  value       = aws_wafv2_web_acl.waf.arn
}

output "waf_id" {
  description = "The ID of the created WAF WebACL"
  value       = aws_wafv2_web_acl.waf.id
}