variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "simpletimeservice-vpc"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "simpletimeservice-cluster"
}

variable "service_port" {
  description = "Port on which the service runs in the container"
  type        = number
  default     = 8080
}

variable "ecs_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "256"
}

variable "ecs_memory" {
  description = "Memory for the ECS task (in MiB)"
  type        = string
  default     = "512"
}

variable "container_image" {
  description = "Container image to deploy (e.g., from DockerHub)"
  type        = string
  default     = "durgeshsahu14/simpletimeservice:latest"
}
