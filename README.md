# DevOps Challenge

This Repository aims to solve the DevOps Challenge Provided by Particle41. 

## Directory Structure

Below is the Directory structure

```python

├── app
│   ├── app.py              # Python Flask application
│   ├── Dockerfile          # Dockerfile to build the container image
│   └── requirements.txt    # Python dependencies
└── terraform
    ├── main.tf             # Main Terraform configuration
    ├── variables.tf        # Variables definition
    ├── outputs.tf          # Outputs for deployment info (e.g., ALB DNS name)
    └── terraform.tfvars    # Example variable values (do not commit secrets)
```

## Task 1: SimpletTimeService Microservice Application

### Prerequisites
- **Docker:** [Install Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Git:** [Install Git](https://git-scm.com/downloads)

    **1. Clone the Repository:**

    ``` bash

        git clone <repo_url>
        cd <repo_dir>/app
    ```

    **2. Build The Docker Image:**
    ```bash
        docker build -t simpletimeservice .
    ```

    **3. Run the Container:**

    ```bash
        docker run -p 8080:8080 simpletimeservice
    ```

    **4. Test the application by visiting:**

    ```bash
        http://localhost:8080/
    ```
    You Should See a JSON response with the current timestamp and your IP address.

    **5. Publishing the Docker Image:**

    Container is pushed to the dockerhub using below commands
    ```bash 
        docker tag simpletimeservice durgeshsahu14/simpletimeservice:latest
        docker push durgeshsahu14/simpletimeservice:latest
    ```

## Task2: Terraform Infrastructure to Deploy on AWS

### Prerequisites
- **Terraform:** [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- **AWS CLI:** [Install AWS CLI](https://aws.amazon.com/cli/)

### Configure AWS CLI
```bash
   aws configure
```

**AWS Account:**
   
   Ensure your aws user has permissions to create vpcs, ECs clusters and related resources. You can also set resource permissions by **Creating a Custom Policy with Specific Permissions**. 

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformRequiredActions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:DescribeVpcs",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:DescribeSubnets",
        "ecs:CreateCluster",
        "ecs:DeleteCluster",
        "ecs:DescribeClusters",
        "ecs:RegisterTaskDefinition",
        "ecs:DeregisterTaskDefinition",
        "ecs:CreateService",
        "ecs:UpdateService",
        "ecs:DeleteService",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "elasticloadbalancing:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}

```

### How to Attach the Policy via the AWS Management Console
    1. Log in to the **AWS Management Console** and navigate to the **IAM service**.

    2. Select Users from the sidebar, then click on your user (e.g., durgesh).

    3. Click on the **"Add permissions"** button.

    4. Choose **"Attach policies directly"**.

    5. Either:

       - Search for and attach the AdministratorAccess policy (for testing), or

       - Create a new policy using the custom JSON above and attach it to your user.

    6.Save the changes.

### Deploying the Infrastructure

**1. Navigate to the terraform directory:**

```bash 
   cd terraform
```

**2. Initialize Terraform:**

```bash 
   terraform init
 ```  

**3. Review the plan:**

```bash 
   terraform plan
``` 

**4. Apply the configuration:**

```bash 
    terraform apply
``` 
**Confirm everything when prompted on terminal.**

**5. After deployment, note the ALB DNS name from Terraform outputs and access your service via:**

```bash
   http://<alb_dns_name>/
```   

