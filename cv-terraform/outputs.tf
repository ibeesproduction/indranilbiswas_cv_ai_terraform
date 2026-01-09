output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for website content"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "website_url" {
  description = "Website URL"
  value       = "https://${var.domain_name}"
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.website.arn
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.website.arn
}

# ============================================================================
# Visitor Counter Outputs
# ============================================================================

output "visitor_counter_api_url" {
  description = "API Gateway URL for visitor counter (⚠️ ADD THIS TO index.html with /count endpoint)"
  value       = "${aws_apigatewayv2_stage.visitor_counter.invoke_url}/count"
}

output "visitor_counter_dynamodb_table" {
  description = "Name of the DynamoDB table for visitor counter"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "visitor_counter_lambda_arn" {
  description = "Lambda function ARN for visitor counter"
  value       = aws_lambda_function.visitor_counter.arn
}

# ============================================================================
# 🎯 Quick Reference - Copy/Paste Commands
# ============================================================================

output "quick_commands" {
  description = "Quick reference commands for deployment"
  value       = <<-EOT
    
    ╔════════════════════════════════════════════════════════════════════════════╗
    ║                     🚀 DEPLOYMENT QUICK REFERENCE                           ║
    ╚════════════════════════════════════════════════════════════════════════════╝
    
    📝 STEP 1: Update index.html with Lambda URL
    ─────────────────────────────────────────────────────────────────────────────
    
    Lambda Function URL: ${aws_apigatewayv2_stage.visitor_counter.invoke_url}/count}
    
    Find this in index.html (line ~380):
      const apiUrl = 'LAMBDA_FUNCTION_URL_HERE';
    
    Replace with:
      const apiUrl = '${aws_apigatewayv2_stage.visitor_counter.invoke_url}/count}';
    
    ─────────────────────────────────────────────────────────────────────────────
    
    📤 STEP 2: Deploy to S3
    ─────────────────────────────────────────────────────────────────────────────
    
    aws s3 sync ./modular-cv-website/ s3://${aws_s3_bucket.website.id}/ --delete
    ─────────────────────────────────────────────────────────────────────────────
    
    🔄 STEP 3: Invalidate CloudFront Cache
    ─────────────────────────────────────────────────────────────────────────────
    
    aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.website.id} --paths "/*"
    
    ─────────────────────────────────────────────────────────────────────────────
    
    🌐 STEP 4: Visit Your Website
    ─────────────────────────────────────────────────────────────────────────────
    
    Website URL: https://${var.domain_name}
    
    Expected: Visitor counter displays: 👁️ Page Visits: [number]
    
    ─────────────────────────────────────────────────────────────────────────────
    
    🔍 MONITORING COMMANDS
    ─────────────────────────────────────────────────────────────────────────────
    
    # View visitor count in DynamoDB:
    aws dynamodb get-item \
      --table-name ${aws_dynamodb_table.visitor_counter.name} \
      --key '{"id": {"S": "visitor-count"}}'
    
    # View Lambda logs:
    aws logs tail /aws/lambda/cv-visitor-counter --follow
    
    # Test Lambda directly:
    curl -X POST ${aws_apigatewayv2_stage.visitor_counter.invoke_url}/count}
    
    ─────────────────────────────────────────────────────────────────────────────
    
    ✅ Infrastructure Deployed:
       • CloudFront: ${aws_cloudfront_distribution.website.id}
       • S3 Bucket: ${aws_s3_bucket.website.id}
       • Lambda: cv-visitor-counter
       • DynamoDB: ${aws_dynamodb_table.visitor_counter.name}
       • Website: https://${var.domain_name}
    
    💰 Monthly Cost: ~$2-5 (CloudFront + Route 53, Lambda/DynamoDB free tier)
    
    ╚════════════════════════════════════════════════════════════════════════════╝
  EOT
}
