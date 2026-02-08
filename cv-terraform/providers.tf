# Default provider for primary region (ap-southeast-2)
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Provider alias for us-east-1 (required for CloudFront ACM certificates)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = var.tags
  }
}
