
# Autonomous Cloud FinOps Platform

<p align="center">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python"/>
  <img src="https://img.shields.io/badge/Amazon_AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS"/>
  <img src="https://img.shields.io/badge/Serverless-FD5750?style=for-the-badge&logo=serverless&logoColor=white" alt="Serverless"/>
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform"/>
</p>

<p align="center">
  An autonomous platform on AWS that intelligently optimizes the resource lifecycle, cutting cloud spend on developer environments by over 50% with zero manual intervention.
</p>

---

## 💡 The Problem Statement

This idea actually came from a very common student problem. While working on group projects, my friends and I would constantly spin up cloud servers on AWS for development or testing. We’d use them for a few hours and then, inevitably, forget to shut them down. A week later, we'd get a surprisingly high bill for resources that were just sitting idle 90% of the time. I realized that if this is a headache for a few students, it must be a massive, multi-million dollar problem for large tech companies with thousands of developers.

## 🚀 The Solution: A Technical Deep-Dive

My solution was to build an **Autonomous Cloud FinOps Platform** using an event-driven architecture on AWS. The entire system is serverless to minimize its own operational cost. The central component is an **AWS Lambda function**, written in Python using the **Boto3 SDK**. This function contains the core logic for discovering, hibernating, and waking up resources.

I used **Amazon EventBridge** to schedule the operations. Two cron jobs are configured: a 'shutdown' job that runs every evening and a 'startup' job that runs every morning. When triggered, EventBridge invokes the central Lambda function.

The Lambda function then scans for all resources across the account that have specific tags, like `env:dev` or `project:staging`. It identifies running **EC2 instances** and **RDS databases** that match these tags and executes the `stop_instances` or `stop_db_instance` API calls. To handle state and prevent errors, it logs the status of each action to a **DynamoDB table**.

For security, the Lambda function operates under a specific **IAM Role** with a least-privilege policy, granting it only the necessary permissions to describe and modify the state of tagged EC2 and RDS resources. This ensures the automation is both effective and secure, directly addressing cloud waste without manual oversight.

## 🛠️ Tech Stack

- **Language:** Python
- **Cloud Provider:** AWS
- **Core Services:** AWS Lambda, Amazon EventBridge, DynamoDB, IAM
- **SDK:** Boto3
- **Infrastructure as Code:** Terraform
- **Core Concepts:** FinOps, Cloud Cost Optimization, Serverless Architecture, Event-Driven Systems

## ⚙️ Deployment

### Prerequisites

Ensure you have an AWS account, Terraform, and the AWS CLI configured.

### Deployment with Terraform

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/TheSensibleLunatic/autonomous-finops-platform.git
    ```
2.  **Navigate to the terraform directory:**
    ```bash
    cd autonomous-finops-platform/terraform
    ```
3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```
4.  **Apply the configuration:**
    ```bash
    terraform apply
    ```

## 📜 License

This project is licensed under the MIT License - see the `LICENSE` file for details.
