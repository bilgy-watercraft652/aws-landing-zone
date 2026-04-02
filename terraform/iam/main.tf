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

# Provider for Dev Account
provider "aws" {
  region = "us-east-1"
  alias  = "dev"

  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account_id}:role/OrganizationAccountAccessRole"
  }
}

# Provider for Prod Account
provider "aws" {
  region = "us-east-1"
  alias  = "prod"

  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/OrganizationAccountAccessRole"
  }
}

# Variables
variable "dev_account_id" {
  description = "Dev Account ID"
  type        = string
}

variable "prod_account_id" {
  description = "Prod Account ID"
  type        = string
}

variable "management_account_id" {
  description = "Management Account ID"
  type        = string
}

# Get current account ID
data "aws_caller_identity" "current" {}

# ============================================
# Developer Role in Dev Account
# ============================================

resource "aws_iam_role" "developer" {
  provider = aws.dev
  name     = "DeveloperRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.management_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "developer-access"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "Developer Role"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Developer policy - Full development permissions
resource "aws_iam_role_policy" "developer" {
  provider = aws.dev
  name     = "DeveloperPolicy"
  role     = aws_iam_role.developer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2FullAccess"
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3FullAccess"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "LambdaFullAccess"
        Effect = "Allow"
        Action = [
          "lambda:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMReadOnly"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "DynamoDBFullAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "RDSFullAccess"
        Effect = "Allow"
        Action = [
          "rds:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "VPCFullAccess"
        Effect = "Allow"
        Action = [
          "vpc:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================
# ReadOnly Role in Prod Account
# ============================================

resource "aws_iam_role" "readonly" {
  provider = aws.prod
  name     = "ReadOnlyRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.management_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "readonly-access"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "ReadOnly Role"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed ReadOnlyAccess policy
resource "aws_iam_role_policy_attachment" "readonly" {
  provider   = aws.prod
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ============================================
# Outputs
# ============================================

output "developer_role_arn" {
  value       = aws_iam_role.developer.arn
  description = "ARN of the Developer role in Dev account"
}

output "readonly_role_arn" {
  value       = aws_iam_role.readonly.arn
  description = "ARN of the ReadOnly role in Prod account"
}

output "assume_developer_command" {
  value       = "aws sts assume-role --role-arn ${aws_iam_role.developer.arn} --role-session-name developer-session --external-id developer-access"
  description = "Command to assume Developer role"
}

output "assume_readonly_command" {
  value       = "aws sts assume-role --role-arn ${aws_iam_role.readonly.arn} --role-session-name readonly-session --external-id readonly-access"
  description = "Command to assume ReadOnly role"
}
