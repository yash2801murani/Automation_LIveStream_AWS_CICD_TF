Project Overview
This project enables automated cloud infrastructure provisioning and live streaming, using Jenkins and Terraform for CI/CD. The pipeline deploys AWS resources including EC2, IVS, S3, and CloudFront. Streaming credentials are securely emailed to the admin, and live streams are distributed to end users via CloudFront.

Architecture
Dev pushes Terraform code to GitHub

EC2 hosts Jenkins and Terraform for automated job execution

Jenkins job executes Terraform to provision AWS resources (IVS, S3, CloudFront)

Jenkins emails IVS stream credentials to the admin

Source camera connects to EC2, streams content to IVS using credentials

IVS output is saved to S3 bucket as HTML page

CloudFront serves the live stream to end users

Prerequisites
AWS account with access to EC2, IVS, S3, CloudFront

IAM role with necessary permissions assigned to Jenkins EC2 instance

GitHub repository for Terraform code

Jenkins and Terraform installed on EC2

SMTP access (e.g., AWS SES) for sending emails from Jenkins​​

Setup Instructions
Clone Terraform Repository

git clone <your-repo-url>

Install Requirements on EC2

Install Jenkins: Follow official docs for AWS setup​

Install Terraform: Download from terraform.io

Configure IAM and Security

Attach IAM role with permissions to the Jenkins EC2

Configure security groups for access (HTTP for Jenkins, custom for IVS streaming)

Configure Jenkins Job

Set up pipeline to pull TF code from GitHub

Use Jenkins plugins for AWS credentials and Terraform steps

Job runs Terraform to create IVS, S3, CloudFront

Email Stream Credentials

Configure Jenkins email extension with SMTP service (AWS SES recommended)

After resource creation, the job sends IVS stream key and ingest server to admin

Camera Source Setup

Admin receives credentials via email

Camera (or streaming encoder) uses these credentials to push content via EC2 to IVS

Serve Stream to Users

IVS output written to S3 bucket (HTML)

CloudFront distribution delivers S3 content to end users

Usage
Push updates to your Terraform GitHub repo to trigger deployment changes.

Admin can re-request stream credentials from Jenkins email job.

End users view live streamed HTML page via CloudFront URL.

Troubleshooting
Ensure IAM role allows necessary AWS actions.

Validate Jenkins SMTP settings for email delivery.

Check EC2 instance resource limits for Jenkins jobs and TF execution.