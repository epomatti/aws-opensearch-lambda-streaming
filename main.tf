provider "aws" {
  region = local.region
}

variable "region" {
  type = string
}

variable "master_user_name" {
  type = string
}

variable "master_user_password" {
  type      = string
  sensitive = true
}

### Locals ###

data "aws_caller_identity" "current" {}

locals {
  region               = var.region
  account_id           = data.aws_caller_identity.current.account_id
  master_user_name     = var.master_user_name
  master_user_password = var.master_user_password
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
    iops        = 3000
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = local.master_user_name
      master_user_password = local.master_user_password
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
