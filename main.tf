provider "aws" {
  region = local.region
}

locals {
  region = "sa-east-1"
}

### S3 ###

resource "aws_s3_bucket" "main" {
  bucket = "opensearch-${local.region}-epomatti"

  force_destroy = true

  tags = {
    Name = "opensearch-bucket"
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "movies" {
  bucket         = aws_s3_bucket.main.bucket
  key            = "bulk_movies.json"
  content_base64 = filebase64("${path.module}/bulk_movies.json")
  content_type   = "application/json"
}

### OpenSearch ###

resource "aws_opensearch_domain" "main" {
  domain_name           = "opensearch-main"
  engine_version = "OpenSearch_1.3"

  cluster_config {
    instance_type  = "t3.medium.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 100
    volume_type = "gp3"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
CONFIG
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# resource "aws_opensearch_domain_policy" "main" {
#   domain_name = aws_opensearch_domain.main.domain_name

#   access_policies = <<POLICIES
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "es:*",
#             "Principal": "*",
#             "Effect": "Allow",
#             "Resource": "${aws_opensearch_domain.main.arn}/*"
#         }
#     ]
# }
# POLICIES
# }
