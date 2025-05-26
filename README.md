# 🔧 Run EC2 Command via AWS SSM

> A GitHub Action to run remote bash commands on your EC2 instance using AWS Systems Manager (SSM), without requiring SSH or manually managing AWS credentials.

## 📦 Features

- ✅ Executes arbitrary shell commands remotely
- 🔐 No SSH required – uses AWS SSM
- 🔐 Supports GitHub OIDC — no need to store long-lived AWS keys
- 🪄 Works with `AmazonLinux2`, `Ubuntu`, and other SSM-enabled EC2 AMIs

---

## 🚀 Usage

### 1. Prerequisites

- EC2 instance **must have SSM Agent installed and running**
- EC2 instance **must be in a public or accessible subnet**
- EC2's IAM Role should allow `ssm:SendCommand`, `ssm:GetCommandInvocation`
- GitHub Workflow must authenticate to AWS (see below)

---

### 2. Authentication

This action does **not** use hardcoded AWS credentials.

Instead, you must use [`aws-actions/configure-aws-credentials`](https://github.com/aws-actions/configure-aws-credentials) to authenticate. This action supports both:

#### ✅ **Option 1: GitHub OIDC (recommended)**

Use short-lived credentials with GitHub’s native OIDC support. No need to store `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY`.

```yaml
- name: Configure AWS Credentials (OIDC)
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: {{ secret.AWS_ROLE_ARN }}
    aws-region: {{ secrets.AWS_REGION }}

```

Make sure you have:
	•	Created an IAM Role with a trust policy for GitHub’s OIDC provider
	•	Granted the role permissions for SSM (ssm:SendCommand, etc.)

⚠️ Option 2: Use AWS Keys (not recommended)

You can still pass aws-access-key-id and aws-secret-access-key via GitHub Secrets:

```yaml
- name: Configure AWS Credentials (Keys)
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ap-southeast-1

```
⸻

3. Example Workflow

```yaml
name: Deploy via AWS SSM

on:
  push:
    branches: [main]

permissions:
    id-token: write
    contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: {{ secret.AWS_ROLE_ARN }}
          aws-region: {{ secrets.AWS_REGION }}

      - name: Run EC2 Command via AWS SSM
        uses: thomasvjoseph/aws-ssm-send@v1.0.0
        with:
          instance-id: {{ secrets.INSTANCE_ID }}
          region: {{ secrets.AWS_REGION }}
          commands: |
            echo "Hello from GitHub Actions!"
            echo "Creating a file..."
            echo "Hello from GitHub Actions!" > /home/ec2-user/hello.txt


```

## 📥 Inputs


| Name             | Required | Description                                       |
| ---------------- | -------- | ------------------------------------------------  |
| aws-actions/configure-aws-credentials | ✅ Yes    | Configure AWS credentials for GitHub OIDC in GitHub workflow |
| instance-id      | ✅ Yes    | EC2 instance ID                                  |
| region           | ✅ Yes    | AWS region where the instance resides            |
| commands         | ✅ Yes    | Multiline bash commands to execute               |


⸻

## 🧪 Output

The action prints:
	•	Command ID
	•	Execution status
	•	Full command output (stdout and stderr)

⸻

🛠 Example Commands

```yaml
commands: |
  echo "Deploying app..."
  cd /var/www/html
  git pull origin main
  sudo systemctl restart nginx

```

⸻

## 🔐 Security Tip

Prefer using GitHub OIDC for secure, short-lived credentials instead of static AWS keys in secrets.

Learn more here:

👉 https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html

👉 https://github.com/aws-actions/configure-aws-credentials#oidc

⸻

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

## Author:  
thomas joseph
- [linkedin](https://www.linkedin.com/in/thomas-joseph-88792b132/)
- [medium](https://medium.com/@thomasvjoseph)