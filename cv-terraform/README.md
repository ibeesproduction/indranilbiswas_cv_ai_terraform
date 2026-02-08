# Static CV Website on AWS with Terraform

Production-ready Terraform infrastructure for deploying a static CV website on AWS using S3, CloudFront, ACM, and Route 53.

## Architecture

- **S3**: Private bucket for website content (no public access)
- **CloudFront**: CDN with HTTPS, custom domain, security headers
- **ACM**: SSL/TLS certificate (DNS validation)
- **Route 53**: DNS records pointing to CloudFront
- **Security**: Origin Access Control (OAC), HSTS, CSP, and modern TLS

## Prerequisites

1. **AWS Account** with appropriate permissions:
   - S3, CloudFront, ACM, Route 53, IAM
2. **Terraform** >= 1.5 installed ([Download](https://www.terraform.io/downloads))
3. **AWS CLI** configured with credentials ([Setup Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html))
4. **Existing Route 53 Hosted Zone** for `ibeesproduction.com`

## Quick Start

### 1. Configure AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-southeast-2"
```

### 2. Initialize Terraform

```bash
# Navigate to project directory
cd cv-website-terraform

# Initialize Terraform (downloads providers)
terraform init
```

### 3. Review and Customize Variables (Optional)

Edit `terraform.tfvars` to customize:

```hcl
domain_name      = "indranilbiswas.ibeesproduction.com"
hosted_zone_name = "ibeesproduction.com"
aws_region       = "ap-southeast-2"
enable_logging   = false

tags = {
  Project     = "CV-Website"
  Owner       = "Indranil Biswas"
  Environment = "Production"
  ManagedBy   = "Terraform"
}
```

### 4. Plan Infrastructure Changes

```bash
# Review what will be created
terraform plan
```

### 5. Deploy Infrastructure

```bash
# Apply the infrastructure
terraform apply

# Type 'yes' when prompted to confirm
```

**⏱️ Expected Deployment Time**: 30-45 minutes
- ACM Certificate Validation: 5-30 minutes
- CloudFront Distribution: 15-30 minutes

### 6. Upload Website Files

After deployment completes, upload your CV website files:

```bash
# Get the S3 bucket name from outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Sync your local website files to S3
# Replace ./site-content/ with your website directory
aws s3 sync ./site-content/ s3://${BUCKET_NAME}/ \
  --delete \
  --cache-control "public, max-age=3600"

# Invalidate CloudFront cache to see changes immediately
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation \
  --distribution-id ${DISTRIBUTION_ID} \
  --paths "/*"
```

### 7. Access Your Website

```bash
# Get your website URL
terraform output website_url

# Example output: https://indranilbiswas.ibeesproduction.com
```

## Project Structure

```
cv-website-terraform/
├── README.md                 # This file
├── versions.tf              # Terraform and provider version constraints
├── providers.tf             # AWS provider configuration
├── variables.tf             # Input variable definitions
├── main.tf                  # Main infrastructure resources
├── outputs.tf               # Output values
├── terraform.tfvars         # Variable values (optional)
└── .gitignore              # Git ignore file
```

## Resources Created

| Resource Type | Resource Name | Purpose |
|--------------|---------------|---------|
| S3 Bucket | `indranilbiswas-ibeesproduction-com-content` | Website content storage (private) |
| S3 Bucket Policy | - | Grants CloudFront OAC read access |
| CloudFront Distribution | - | CDN with custom domain and HTTPS |
| CloudFront OAC | - | Secure access to S3 bucket |
| CloudFront Response Headers Policy | - | Security headers (HSTS, CSP, etc.) |
| ACM Certificate | - | SSL/TLS certificate in us-east-1 |
| Route 53 A Record | `indranilbiswas.ibeesproduction.com` | IPv4 alias to CloudFront |
| Route 53 AAAA Record | `indranilbiswas.ibeesproduction.com` | IPv6 alias to CloudFront |
| Route 53 Validation Records | - | ACM DNS validation |

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# View specific output
terraform output website_url
terraform output s3_bucket_name
terraform output cloudfront_distribution_id
```

## Security Features

✅ **Private S3 Bucket**: No public access, CloudFront uses OAC  
✅ **HTTPS Only**: HTTP automatically redirects to HTTPS  
✅ **Modern TLS**: Minimum TLS 1.2 (2021 configuration)  
✅ **Security Headers**: HSTS, CSP, X-Frame-Options, X-Content-Type-Options  
✅ **HTTP/2 and HTTP/3**: Enabled for better performance  
✅ **SPA Support**: 403/404 errors route to /index.html  

## Cost Estimate

Monthly costs (approximate):

- **CloudFront**: $0.085/GB + $0.0075 per 10,000 requests
- **S3 Storage**: $0.023/GB (first 50TB)
- **Route 53**: $0.50/hosted zone + $0.40/million queries
- **ACM Certificate**: FREE

**Estimated Monthly Cost** (for low-traffic CV site): **$1-5 USD**

## Maintenance

### Update Website Content

```bash
# Sync new content
aws s3 sync ./site-content/ s3://$(terraform output -raw s3_bucket_name)/ \
  --delete \
  --cache-control "public, max-age=3600"

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

### Monitor Resources

```bash
# CloudFront distribution status
aws cloudfront get-distribution \
  --id $(terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status'

# S3 bucket size
aws s3 ls s3://$(terraform output -raw s3_bucket_name) --summarize --recursive
```

## Troubleshooting

### Issue: Website not loading after deployment

**Possible Causes:**

1. **ACM Certificate not validated**
   ```bash
   aws acm describe-certificate \
     --certificate-arn $(terraform output -raw acm_certificate_arn) \
     --region us-east-1 \
     --query 'Certificate.Status'
   ```
   Status should be `ISSUED`

2. **CloudFront distribution not deployed**
   ```bash
   aws cloudfront get-distribution \
     --id $(terraform output -raw cloudfront_distribution_id) \
     --query 'Distribution.Status'
   ```
   Status should be `Deployed` (takes 15-30 minutes)

3. **DNS not propagated**
   ```bash
   dig indranilbiswas.ibeesproduction.com
   nslookup indranilbiswas.ibeesproduction.com
   ```
   Can take up to 48 hours globally (usually < 1 hour)

4. **No content in S3 bucket**
   ```bash
   aws s3 ls s3://$(terraform output -raw s3_bucket_name)/
   ```
   Ensure `index.html` exists

5. **Browser cache**
   - Clear browser cache
   - Test in incognito/private mode

### Issue: Certificate validation stuck

If ACM certificate validation takes > 30 minutes:

```bash
# Check validation records
aws route53 list-resource-record-sets \
  --hosted-zone-id $(terraform output -raw route53_zone_id) \
  --query "ResourceRecordSets[?Type=='CNAME']"

# Verify hosted zone is correct
aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='ibeesproduction.com.']"
```

## Cleanup

To destroy all resources:

```bash
# WARNING: This will delete all resources including the S3 bucket content
terraform destroy

# Type 'yes' when prompted to confirm
```

**Note**: The Route 53 hosted zone for `ibeesproduction.com` will NOT be deleted as it was not created by this Terraform configuration.

## Advanced Configuration

### Enable CloudFront Logging

Edit `terraform.tfvars`:

```hcl
enable_logging = true
```

Then apply:

```bash
terraform apply
```

Logs will be stored in a separate S3 bucket with 90-day retention.

### Change CloudFront Price Class

To reduce costs, use a cheaper price class:

```hcl
price_class = "PriceClass_100"  # USA, Canada, Europe
# or
price_class = "PriceClass_200"  # USA, Canada, Europe, Asia, Middle East, Africa
```

### Custom Security Headers

Edit the `aws_cloudfront_response_headers_policy` resource in `main.tf` to customize security headers.

## Support

For issues or questions:
- **Terraform Documentation**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **AWS CloudFront**: https://docs.aws.amazon.com/cloudfront/
- **AWS ACM**: https://docs.aws.amazon.com/acm/

## License

This infrastructure code is provided as-is for personal use.
