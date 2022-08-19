provider "aws" {
  region = local.region
}

variable "region" {
  type = string
}

variable "master_user" {
  type = string
}

### Locals ###

data "aws_caller_identity" "current" {}

locals {
  region      = var.region
  account_id  = data.aws_caller_identity.current.account_id
  master_user = var.master_user
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
  domain_name    = "opensearch-main"
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

  advanced_security_options {
    enabled = true
    master_user_options {
      master_user_arn = "arn:aws:iam::${local.account_id}:user/${local.master_user}"
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
}

