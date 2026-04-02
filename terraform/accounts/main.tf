terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Variables for OU IDs
variable "security_ou_id" {
  description = "Security OU ID"
  type        = string
}

variable "workloads_ou_id" {
  description = "Workloads OU ID"
  type        = string
}

# Variables for email addresses
variable "security_email" {
  description = "Email for Security Account"
  type        = string
}

variable "dev_email" {
  description = "Email for Dev Account"
  type        = string
}

variable "prod_email" {
  description = "Email for Prod Account"
  type        = string
}

# Create Security Account
resource "aws_organizations_account" "security" {
  name      = "Security-Account"
  email     = var.security_email
  parent_id = var.security_ou_id

  tags = {
    Environment = "Security"
    ManagedBy   = "Terraform"
  }
}

# Create Dev Account
resource "aws_organizations_account" "dev" {
  name      = "Dev-Account"
  email     = var.dev_email
  parent_id = var.workloads_ou_id

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Create Prod Account
resource "aws_organizations_account" "prod" {
  name      = "Prod-Account"
  email     = var.prod_email
  parent_id = var.workloads_ou_id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "security_account_id" {
  value = aws_organizations_account.security.id
}

output "dev_account_id" {
  value = aws_organizations_account.dev.id
}

output "prod_account_id" {
  value = aws_organizations_account.prod.id
}

