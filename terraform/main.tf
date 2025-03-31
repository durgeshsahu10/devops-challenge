provider "aws" {
  region = var.aws_region
}

# Grant the IAM user permission to call ec2:DescribeAvailabilityZones.
resource "aws_iam_user_policy" "allow_describe_az" {
  name = "allow_describe_az"
  user = "durgesh"  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "ec2:DescribeAvailabilityZones",
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

# Fetch available availability zones (we use the first 2)
data "aws_availability_zones" "available" {}

# Create a VPC with 2 public and 2 private subnets using the AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name
}

# Create an IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.ecs_cluster_name}-task-execution-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Security Group for the Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "${var.ecs_cluster_name}-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for the ECS service (allow traffic from ALB only)
resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.ecs_cluster_name}-service-sg"
  description = "Allow traffic from ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = var.service_port
    to_port         = var.service_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "${var.ecs_cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

# Create a Target Group for the ECS service
resource "aws_lb_target_group" "target_group" {
  name        = "${var.ecs_cluster_name}-tg"
  port        = var.service_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create a Listener for the ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Define the ECS Task Definition for the SimpleTimeService container
resource "aws_ecs_task_definition" "simpletimeservice" {
  family                   = "simpletimeservice"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name         = "simpletimeservice"
    image        = var.container_image
    portMappings = [{
      containerPort = var.service_port
      hostPort      = var.service_port
      protocol      = "tcp"
    }]
    essential = true
  }])
}

# Create an ECS Service to run the container
resource "aws_ecs_service" "service" {
  name            = "simpletimeservice"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.simpletimeservice.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "simpletimeservice"
    container_port   = var.service_port
  }

  depends_on = [aws_lb_listener.listener]
}

# Output the ALB DNS name to access the service
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}
