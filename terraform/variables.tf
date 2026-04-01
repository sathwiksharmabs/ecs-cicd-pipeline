variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "key_name" {
  description = "Keypair for EC2"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  default     = "t2.medium"
}

variable "ecs_instance_type" {
  description = "EC2 instance type for ECS (if needed)"
  default     = "t3.medium"
}

variable "docker_image_tag" {
  description = "Default Docker image tag"
  default     = "1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}