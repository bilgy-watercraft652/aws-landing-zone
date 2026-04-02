terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider (Management Account)
provider "aws" {
  region = "us-east-1"
}

# Provider for Security Account
provider "aws" {
  region = "us-east-1"
  alias  = "security"

  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }
}

# Variables
variable "security_account_id" {
  description = "Security Account ID"
  type        = string
}

variable "organization_id" {
  description = "AWS Organization ID"
  type        = string
}

# Get current account ID
data "aws_caller_identity" "current" {}

# ============================================
# S3 Bucket for CloudTrail Logs
# ============================================

resource "aws_s3_bucket" "cloudtrail" {
  provider = aws.security
  bucket   = "cloudtrail-logs-${var.security_account_id}"

  tags = {
    Name        = "CloudTrail Organization Logs"
    Environment = "Security"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "cloudtrail" {
  provider = aws.security
  bucket   = aws_s3_bucket.cloudtrail.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  provider = aws.security
  bucket   = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  provider = aws.security
  bucket   = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  provider = aws.security
  bucket   = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ============================================
# CloudTrail Organization Trail
# ============================================

resource "aws_cloudtrail" "organization" {
  # Uses default provider (Management Account) - NOT Security Account

  name                          = "organization-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::*/*"]
    }
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# ============================================
# S3 Bucket for Config Logs
# ============================================

resource "aws_s3_bucket" "config" {
  provider = aws.security
  bucket   = "config-logs-${var.security_account_id}"

  tags = {
    Name        = "AWS Config Logs"
    Environment = "Security"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "config" {
  provider = aws.security
  bucket   = aws_s3_bucket.config.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  provider = aws.security
  bucket   = aws_s3_bucket.config.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "config" {
  provider = aws.security
  bucket   = aws_s3_bucket.config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for Config
resource "aws_s3_bucket_policy" "config" {
  provider = aws.security
  bucket   = aws_s3_bucket.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config.arn
      },
      {
        Sid    = "AWSConfigBucketExistenceCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.config.arn
      },
      {
        Sid    = "AWSConfigBucketWrite"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ============================================
# IAM Role for Config
# ============================================

resource "aws_iam_role" "config" {
  provider = aws.security
  name     = "AWSConfigRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "AWS Config Service Role"
  }
}

# Attach AWS managed policy (CORRECTED ARN with underscore)
resource "aws_iam_role_policy_attachment" "config" {
  provider   = aws.security
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Additional policy for S3 access
resource "aws_iam_role_policy" "config_s3" {
  provider = aws.security
  name     = "ConfigS3Policy"
  role     = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          aws_s3_bucket.config.arn,
          "${aws_s3_bucket.config.arn}/*"
        ]
      }
    ]
  })
}

# ============================================
# AWS Config Recorder
# ============================================

resource "aws_config_configuration_recorder" "main" {
  provider = aws.security
  name     = "organization-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# Config delivery channel (with proper dependencies)
resource "aws_config_delivery_channel" "main" {
  provider       = aws.security
  name           = "organization-config-channel"
  s3_bucket_name = aws_s3_bucket.config.id

  depends_on = [
    aws_config_configuration_recorder.main,
    aws_s3_bucket_policy.config
  ]
}

# Start recorder
resource "aws_config_configuration_recorder_status" "main" {
  provider   = aws.security
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

# ============================================
# AWS Config Rules
# ============================================

# S3 bucket encryption
resource "aws_config_config_rule" "s3_bucket_encryption" {
  provider = aws.security
  name     = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# IAM password policy
resource "aws_config_config_rule" "iam_password_policy" {
  provider = aws.security
  name     = "iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Root MFA enabled
resource "aws_config_config_rule" "root_mfa_enabled" {
  provider = aws.security
  name     = "root-account-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# CloudTrail enabled
resource "aws_config_config_rule" "cloudtrail_enabled" {
  provider = aws.security
  name     = "cloudtrail-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# ============================================
# GuardDuty - Use Existing Detector
# ============================================

# Use existing GuardDuty detector (data source instead of resource)
data "aws_guardduty_detector" "security" {
  provider = aws.security
}

# Enable GuardDuty organization admin
resource "aws_guardduty_organization_admin_account" "main" {
  admin_account_id = var.security_account_id

  depends_on = [data.aws_guardduty_detector.security]
}

# Auto-enable for new accounts (FIXED: using new parameter)
resource "aws_guardduty_organization_configuration" "main" {
  provider                         = aws.security
  auto_enable_organization_members = "ALL"
  detector_id                      = data.aws_guardduty_detector.security.id

  datasources {
    s3_logs {
      auto_enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
  }

  depends_on = [aws_guardduty_organization_admin_account.main]
}

# ============================================
# Outputs
# ============================================

output "cloudtrail_arn" {
  value       = aws_cloudtrail.organization.arn
  description = "ARN of the organization CloudTrail"
}

output "cloudtrail_bucket" {
  value       = aws_s3_bucket.cloudtrail.id
  description = "S3 bucket for CloudTrail logs"
}

output "config_bucket" {
  value       = aws_s3_bucket.config.id
  description = "S3 bucket for Config logs"
}

output "guardduty_detector_id" {
  value       = data.aws_guardduty_detector.security.id
  description = "GuardDuty detector ID"
}

output "config_recorder_name" {
  value       = aws_config_configuration_recorder.main.name
  description = "AWS Config recorder name"
}
