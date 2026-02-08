# Quick Start Guide

Get your CV website live on AWS in under an hour!

## 5-Minute Setup

### Prerequisites Check

```bash
# Check Terraform
terraform version  # Should be >= 1.5.0

# Check AWS CLI
aws --version

# Verify AWS credentials
aws sts get-caller-identity
```

### Deploy in 5 Commands

```bash
# 1. Navigate to project
cd cv-website-terraform

# 2. Initialize Terraform
terraform init

# 3. (Optional) Customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars if needed

# 4. Deploy infrastructure (30-45 min)
terraform apply

# 5. Upload website content
aws s3 sync example-site/ s3://$(terraform output -raw s3_bucket_name)/
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

### Access Your Site

```bash
terraform output website_url
# Open the URL in your browser
```

## What Gets Created?

- ✅ Private S3 bucket for website files
- ✅ CloudFront CDN distribution (global)
- ✅ SSL certificate (free, auto-renewing)
- ✅ DNS records (your custom domain)
- ✅ Security headers and HTTPS enforcement

## Estimated Costs

**~$1-5 USD/month** for low-traffic CV website

## Next Steps

1. **Customize Content**: Edit `example-site/index.html` with your CV
2. **Add Assets**: Upload images, PDFs, etc. to S3
3. **Monitor**: Check AWS Console for metrics
4. **Update**: Run `terraform apply` for infrastructure changes

## Cleanup

To remove everything:

```bash
terraform destroy
# Type 'yes' to confirm
```

## Need Help?

- 📖 **Detailed Guide**: See `DEPLOYMENT_GUIDE.md`
- 🏗️ **Architecture**: See `ARCHITECTURE.md`
- 📂 **Project Structure**: See `PROJECT_STRUCTURE.md`
- 📋 **Main Docs**: See `README.md`

---

**Total Time**: ~45 minutes (mostly waiting for AWS to provision resources)
