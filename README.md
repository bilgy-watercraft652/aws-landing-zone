# AWS Landing Zone - Multi-Account Security Architecture

A production-grade AWS Landing Zone implementation demonstrating enterprise-level security architecture, organizational governance, and Infrastructure as Code best practices.

## 🎯 Project Overview

This project implements a secure, scalable AWS multi-account architecture aligned with banking and financial services compliance requirements. Built entirely with Terraform, it demonstrates enterprise cloud engineering skills including organizational security policies, centralized logging, threat detection, and cross-account access management.

**Project Duration:** 2 days (April 1-2, 2026)
**Infrastructure as Code:** Terraform 1.0+
**AWS Services:** 15+ services integrated

---

## 🏗️ Architecture

AWS Organization │ ├── Management Account (XXXXXXXXXXXX) │ ├── Organization Trail (CloudTrail) │ └── Cross-Account Access Management │ ├── Security OU │ └── Security Account (XXXXXXXXXXXX) │ ├── Centralized CloudTrail Logs │ ├── AWS Config (Compliance Monitoring) │ ├── GuardDuty (Threat Detection) │ └── Encrypted S3 Buckets │ └── Workloads OU (SCPs Applied) ├── Dev Account (XXXXXXXXXXXX) │ ├── DeveloperRole (Full Dev Permissions) │ ├── Root User Denied │ ├── MFA Required │ └── Region Restricted │ └── Prod Account (XXXXXXXXXXXX) ├── ReadOnlyRole (View-Only Access) ├── Root User Denied ├── MFA Required └── Region Restricted


---

## ✨ Key Features

### 🔐 Security & Compliance
- **Service Control Policies (SCPs)** - Organizational security guardrails
- **CloudTrail Organization Trail** - Centralized audit logging across all accounts
- **AWS Config** - Configuration tracking with 4 compliance rules
- **GuardDuty** - Automated threat detection with delegated administration
- **Encrypted S3 Buckets** - AES-256 encryption for all log storage

### 🏢 Multi-Account Architecture
- **Organizational Units** - Logical separation (Security OU, Workloads OU)
- **Member Accounts** - Dedicated accounts for Security, Development, and Production
- **Cross-Account IAM Roles** - Secure assume role patterns with external ID validation

### 🛡️ Security Guardrails
- **Root User Access Denied** - Prevents use of root credentials
- **MFA Enforcement** - Required for sensitive operations (with automation exemptions)
- **Region Restrictions** - Operations limited to approved regions (us-east-1, us-west-2, eu-west-1)

### 🔄 Infrastructure as Code
- **100% Terraform** - All infrastructure defined as code
- **Modular Design** - Separate modules for each phase
- **Version Controlled** - Ready for Git-based workflows

---

## 📋 Prerequisites

- AWS Account with Organizations enabled
- AWS CLI configured with appropriate credentials
- Terraform 1.0 or later
- macOS (instructions provided for macOS)
- Basic understanding of AWS services

---

## 🚀 Deployment Guide

### Phase 1: AWS Organizations Structure

```bash
cd terraform/organizations
terraform init
terraform plan
terraform apply

Creates:

    Root organization
    Security OU
    Workloads OU

Phase 2: Member Accounts

bash

cd terraform/accounts
nano terraform.tfvars  # Add your email addresses
terraform init
terraform plan
terraform apply

Creates:

    Security Account
    Dev Account
    Prod Account

Note: Verify email addresses in Gmail using the + alias feature (e.g., youremail+aws-dev@gmail.com)
Phase 3: Service Control Policies

Enable SCPs first:

bash

aws organizations enable-policy-type \
  --root-id $(aws organizations list-roots --query 'Roots.Id' --output text) \
  --policy-type SERVICE_CONTROL_POLICY

Deploy SCPs:

bash

cd terraform/scp
nano terraform.tfvars  # Add your Workloads OU ID
terraform init
terraform plan
terraform apply

Creates:

    Deny Root User policy
    Require MFA policy (with IAM automation exemptions)
    Restrict Regions policy

Phase 4: Centralized Security Logging

Enable CloudTrail service access:

bash

aws organizations enable-aws-service-access \
  --service-principal cloudtrail.amazonaws.com

Deploy security infrastructure:

bash

cd terraform/security
nano terraform.tfvars  # Add Security Account ID and Organization ID
terraform init
terraform plan
terraform apply

Creates:

    CloudTrail organization trail
    AWS Config recorder and delivery channel
    4 Config compliance rules
    GuardDuty with delegated administration
    Encrypted S3 buckets for logs

Phase 5: Cross-Account IAM Roles

bash

cd terraform/iam
nano terraform.tfvars  # Add account IDs
terraform init
terraform plan
terraform apply

Creates:

    Developer role in Dev Account
    ReadOnly role in Prod Account
    Cross-account trust relationships

🧪 Testing Cross-Account Access

Assume Developer Role:

bash

aws sts assume-role \
  --role-arn arn:aws:iam::XXXXXXXXXXXX:role/DeveloperRole \
  --role-session-name developer-session \
  --external-id developer-access

Assume ReadOnly Role:

bash

aws sts assume-role \
  --role-arn arn:aws:iam::XXXXXXXXXXXX:role/ReadOnlyRole \
  --role-session-name readonly-session \
  --external-id readonly-access

🛠️ Troubleshooting
Issue: "PolicyTypeNotEnabledException"

Solution: Enable SCPs in your organization:

bash

aws organizations enable-policy-type \
  --root-id $(aws organizations list-roots --query 'Roots.Id' --output text) \
  --policy-type SERVICE_CONTROL_POLICY

Issue: "CloudTrailAccessNotEnabledException"

Solution: Enable CloudTrail service access:

bash

aws organizations enable-aws-service-access \
  --service-principal cloudtrail.amazonaws.com

Issue: "AccessDenied" when creating IAM roles

Solution: Update the RequireMFA SCP to exempt IAM role management operations (see Phase 3 configuration)
Issue: "Trail already exists"

Solution: Import existing trail:

bash

terraform import aws_cloudtrail.organization organization-trail

Issue: "Detector already exists" (GuardDuty)

Solution: Use data source instead of resource in Terraform configuration
Issue: "InvalidEventSelectorsException"

Solution: Correct the S3 data resource ARN format from arn:aws:s3:::*/ to arn:aws:s3:::*/*
📁 Project Structure

aws-landing-zone/
├── README.md
├── .gitignore
├── project-ids.txt (excluded from Git)
└── terraform/
    ├── organizations/
    │   ├── main.tf
    │   └── terraform.tfvars
    ├── accounts/
    │   ├── main.tf
    │   └── terraform.tfvars
    ├── scp/
    │   ├── main.tf
    │   └── terraform.tfvars
    ├── security/
    │   ├── main.tf
    │   └── terraform.tfvars
    └── iam/
        ├── main.tf
        └── terraform.tfvars

🎓 Skills Demonstrated

    Multi-Account Architecture - Enterprise AWS Organizations design
    Security Governance - Service Control Policies at organizational scale
    Centralized Logging - CloudTrail, Config, GuardDuty integration
    Threat Detection - GuardDuty with delegated administration
    Compliance Monitoring - AWS Config rules and compliance tracking
    Cross-Account Access - IAM roles with least privilege principles
    Infrastructure as Code - Terraform for repeatable deployments
    Banking-Sector Compliance - Enterprise security requirements
    Troubleshooting - Resolved SCP conflicts, import issues, API errors
    Security Best Practices - Encryption, MFA, region restrictions

🔒 Security Considerations
Service Control Policies

    Root user access is denied across all workload accounts
    MFA is required for sensitive operations (with automation exemptions for IAM role management)
    Regional restrictions limit operations to approved regions only

Encryption

    All S3 buckets use AES-256 encryption
    CloudTrail log file validation enabled
    S3 bucket versioning enabled for audit trails

Access Management

    External ID validation for cross-account role assumptions
    Least privilege IAM policies for Developer and ReadOnly roles
    No long-term credentials - all access via temporary STS tokens

📊 AWS Services Used
Table
Service
	
Purpose
AWS Organizations
	
Multi-account management
Service Control Policies
	
Organizational security guardrails
CloudTrail
	
Audit logging and API tracking
AWS Config
	
Configuration tracking and compliance
GuardDuty
	
Threat detection and security monitoring
IAM
	
Identity and access management
S3
	
Encrypted log storage
STS
	
Temporary security credentials
🎯 Use Cases

This architecture is ideal for:

    Financial Services - Banking and fintech compliance requirements
    Healthcare - HIPAA-compliant multi-account structures
    Enterprise SaaS - Secure multi-tenant architectures
    Regulated Industries - Organizations requiring audit trails and compliance monitoring
    DevOps Teams - Secure development and production environment separation

📚 References

    docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html
    aws.amazon.com/organizations/getting-started/best-practices/
    docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html
    aws.amazon.com/architecture/security-identity-compliance/

👤 Author

Brian AWS Cloud Engineer Johannesburg, South Africa

Contact: bobsdabreezy@gmail.com
📝 License

This project is available for educational and portfolio purposes.
🙏 Acknowledgments

Built as part of a 30-day action plan to demonstrate Senior AWS Cloud Engineer capabilities, with focus on banking-sector security requirements and enterprise compliance standards.

⭐ If you found this project helpful, please consider giving it a star!


