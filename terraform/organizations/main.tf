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

# Get the EXISTING organization (don't create new one)
data "aws_organizations_organization" "main" {}

# Create Security OU
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# Create Workloads OU
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# Output OU IDs
output "security_ou_id" {
  value = aws_organizations_organizational_unit.security.id
}

output "workloads_ou_id" {
  value = aws_organizations_organizational_unit.workloads.id
}

output "organization_id" {
  value = data.aws_organizations_organization.main.id
}

output "root_id" {
  value = data.aws_organizations_organization.main.roots[0].id
}
