# CAIO Phase 14: AWS SaaS Deployment Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-12  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:14`

---

## Executive Summary

Deploy CAIO as a scalable, multi-tenant SaaS solution on AWS infrastructure. This phase enables CAIO to be offered as a cloud service, providing customers with managed AI orchestration without requiring on-premises deployment.

**Key Deliverables:**
1. AWS infrastructure (VPC, EC2/ECS, RDS, S3, ALB, CloudWatch, Secrets Manager, IAM)
2. Multi-tenancy support (tenant isolation, resource quotas, usage tracking)
3. Docker containerization for CAIO application
4. CI/CD pipeline (GitHub Actions → AWS)
5. Monitoring and alerting (CloudWatch metrics, logs, alarms, dashboards)
6. Deployment documentation (architecture, cost estimation, operations)

**Estimated Time:** 2-3 weeks  
**Priority:** High (enables SaaS business model)

**CRITICAL:** This is infrastructure and deployment work, not mathematical algorithm work. MA process is NOT required. However, all infrastructure must be production-ready and secure.

---

## Context & Background

### Current State

- ✅ **CAIO Core:** Fully implemented and production-ready (Phases 0-13 complete)
- ✅ **API Endpoints:** HTTP/REST API fully functional
- ✅ **Database:** SQLite for traceability (needs migration to PostgreSQL for production)
- ✅ **Configuration:** Environment-based configuration system in place
- ✅ **Testing:** Comprehensive E2E tests complete
- ❌ **AWS Infrastructure:** No AWS deployment exists
- ❌ **Multi-Tenancy:** No tenant isolation implemented
- ❌ **Containerization:** No Docker container exists
- ❌ **CI/CD:** No automated deployment pipeline
- ❌ **Cloud Monitoring:** No CloudWatch integration

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal Compatibility:** SaaS deployment makes CAIO accessible to any organization without infrastructure management
- **Mathematical Guarantees:** Multi-tenant isolation ensures guarantees are preserved per tenant
- **Contract-Based Discovery:** Tenant-scoped service registry maintains discovery capabilities
- **Security Built into Math:** AWS security (VPC, IAM, Secrets Manager) enhances CAIO's mathematical security model
- **Scalability:** AWS auto-scaling enables CAIO to handle enterprise-scale workloads

**Reference:** `docs/NORTH_STAR.md` - Universal AI orchestration platform

### Execution Plan Reference

This task implements Phase 14: AWS SaaS Deployment from `docs/operations/EXECUTION_PLAN.md`:

- **14.1:** Design AWS architecture
- **14.2:** Implement infrastructure as code
- **14.3:** Implement multi-tenancy support
- **14.4:** Containerize CAIO application
- **14.5:** Create CI/CD pipeline
- **14.6:** Configure monitoring and alerting
- **14.7:** Create deployment documentation

---

## Step-by-Step Implementation Instructions

### Task 14.1: Design AWS Architecture

**Objective:** Design the AWS infrastructure architecture for CAIO SaaS deployment.

#### Step 1.1: Create Architecture Diagram

**File:** `docs/deployment/AWS_ARCHITECTURE.md`

**Components to Document:**

1. **Network Layer:**
   - VPC with CIDR 10.0.0.0/16
   - Public subnets (10.0.1.0/24, 10.0.2.0/24) in different AZs
   - Private subnets (10.0.10.0/24, 10.0.11.0/24) in different AZs
   - Internet Gateway (for public subnets)
   - NAT Gateway (for private subnet outbound)
   - Route tables

2. **Application Layer:**
   - Application Load Balancer (ALB) in public subnets
   - HTTPS listener with ACM certificate
   - Target groups for CAIO application
   - Health checks configured

3. **Compute Layer:**
   - Option A: EC2 Auto Scaling Group
     - Launch template with CAIO Docker image
     - Auto Scaling Group (min: 2, desired: 4, max: 10)
     - Scaling policies (CPU, memory, request count)
   - Option B: ECS Fargate (recommended)
     - ECS cluster
     - Fargate task definition
     - ECS service with auto-scaling
     - Task placement strategies

4. **Data Layer:**
   - RDS PostgreSQL (multi-AZ for HA)
   - Automated backups (7-day retention)
   - Read replicas (optional, for scaling)
   - Parameter group for CAIO settings

5. **Storage Layer:**
   - S3 bucket for CAIO artifacts (`caio-artifacts-{env}`)
   - S3 bucket for backups (`caio-backups-{env}`)
   - S3 bucket for logs (`caio-logs-{env}`)
   - Lifecycle policies (transition to Glacier after 90 days)

6. **Security Layer:**
   - Security groups (ALB, application, database, bastion)
   - IAM roles (EC2/ECS task role, RDS access, S3 access)
   - Secrets Manager (database credentials, API keys, JWT keys)
   - WAF (optional, for DDoS protection)

7. **Monitoring Layer:**
   - CloudWatch Log Groups (application, ALB access)
   - CloudWatch Metrics (custom CAIO metrics, infrastructure metrics)
   - CloudWatch Alarms (error rate, latency, availability, capacity)
   - CloudWatch Dashboards (overview, performance, errors, infrastructure)

**Architecture Diagram Format:**
- Use ASCII art or Mermaid diagram
- Show data flow (Internet → ALB → Application → Database)
- Show network boundaries (public vs private subnets)
- Label all components with AWS service names

**Example Structure:**
```markdown
# CAIO AWS Architecture

## Overview

CAIO is deployed on AWS using a multi-tier architecture:

```
Internet
  ↓
Application Load Balancer (Public Subnets)
  ↓
CAIO Application (Private Subnets - ECS Fargate)
  ↓
RDS PostgreSQL (Private Subnets - Multi-AZ)
  ↓
S3 Buckets (Artifacts, Backups, Logs)
```

## Network Architecture

- **VPC:** 10.0.0.0/16
- **Public Subnets:** 10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-b)
- **Private Subnets:** 10.0.10.0/24 (AZ-a), 10.0.11.0/24 (AZ-b)

## Component Details

[Detailed descriptions of each component]
```

#### Step 1.2: Define Security Model

**Security Requirements:**

1. **Network Security:**
   - VPC isolation (no direct internet access to application)
   - Security groups with least-privilege rules
   - ALB only accepts HTTPS (port 443)
   - Application only accepts traffic from ALB
   - Database only accepts traffic from application

2. **Access Control:**
   - IAM roles for service access (no hardcoded credentials)
   - Secrets Manager for sensitive data
   - Multi-factor authentication for AWS console access
   - Bastion host for SSH access (if needed)

3. **Data Security:**
   - Encryption at rest (RDS, S3)
   - Encryption in transit (TLS/HTTPS)
   - Database credentials in Secrets Manager
   - API keys in Secrets Manager

4. **Compliance:**
   - Audit logging (CloudTrail)
   - Access logging (ALB access logs)
   - Security monitoring (CloudWatch Security Hub)

#### Step 1.3: Define Scaling Strategy

**Scaling Requirements:**

1. **Application Scaling:**
   - Auto-scaling based on CPU utilization (> 70% for 5 minutes)
   - Auto-scaling based on request count (> 1000 req/min per instance)
   - Auto-scaling based on memory utilization (> 80% for 5 minutes)
   - Minimum 2 instances for HA
   - Maximum 10 instances (adjustable)

2. **Database Scaling:**
   - Vertical scaling (instance size) for initial growth
   - Read replicas for read-heavy workloads
   - Connection pooling (PgBouncer or RDS Proxy)

3. **Cost Optimization:**
   - Reserved instances for baseline capacity
   - Spot instances for non-critical workloads (optional)
   - S3 lifecycle policies for log archival

**Validation:**
- Architecture diagram complete and accurate
- Security model documented
- Scaling strategy defined
- Cost estimates provided

---

### Task 14.2: Implement Infrastructure as Code

**Objective:** Create Terraform or CloudFormation templates for AWS infrastructure.

**Choice:** Use Terraform (more flexible, better state management)

**Directory Structure:**
```
infrastructure/aws/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── security-groups.tf
│   ├── alb.tf
│   ├── ecs.tf
│   ├── rds.tf
│   ├── s3.tf
│   ├── secrets-manager.tf
│   ├── cloudwatch.tf
│   ├── iam.tf
│   └── terraform.tfvars.example
├── README.md
└── ARCHITECTURE.md
```

#### Step 2.1: Create Terraform Configuration Files

**File:** `infrastructure/aws/terraform/main.tf`

**Provider Configuration:**
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "caio-terraform-state"
    key    = "caio-saas/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "CAIO"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

**File:** `infrastructure/aws/terraform/variables.tf`

**Variables:**
```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "caio_image_tag" {
  description = "Docker image tag for CAIO"
  type        = string
  default     = "latest"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage (GB)"
  type        = number
  default     = 100
}

variable "min_capacity" {
  description = "Minimum ECS task count"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum ECS task count"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired ECS task count"
  type        = number
  default     = 4
}
```

**File:** `infrastructure/aws/terraform/vpc.tf`

**VPC Configuration:**
```hcl
# VPC
resource "aws_vpc" "caio" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "caio-${var.environment}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "caio" {
  vpc_id = aws_vpc.caio.id

  tags = {
    Name = "caio-${var.environment}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.caio.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "caio-${var.environment}-public-${count.index + 1}"
    Type = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.caio.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "caio-${var.environment}-private-${count.index + 1}"
    Type = "private"
  }
}

# NAT Gateway (for private subnet outbound)
resource "aws_eip" "nat" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "caio-${var.environment}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "caio" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "caio-${var.environment}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.caio]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.caio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.caio.id
  }

  tags = {
    Name = "caio-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.caio.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.caio[count.index].id
  }

  tags = {
    Name = "caio-${var.environment}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```

**File:** `infrastructure/aws/terraform/security-groups.tf`

**Security Groups:**
```hcl
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "caio-${var.environment}-alb-sg"
  description = "Security group for CAIO Application Load Balancer"
  vpc_id      = aws_vpc.caio.id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "caio-${var.environment}-alb-sg"
  }
}

# Application Security Group
resource "aws_security_group" "app" {
  name        = "caio-${var.environment}-app-sg"
  description = "Security group for CAIO application"
  vpc_id      = aws_vpc.caio.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "caio-${var.environment}-app-sg"
  }
}

# Database Security Group
resource "aws_security_group" "db" {
  name        = "caio-${var.environment}-db-sg"
  description = "Security group for CAIO RDS database"
  vpc_id      = aws_vpc.caio.id

  ingress {
    description     = "PostgreSQL from application"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "caio-${var.environment}-db-sg"
  }
}
```

**File:** `infrastructure/aws/terraform/alb.tf`

**Application Load Balancer:**
```hcl
# ALB
resource "aws_lb" "caio" {
  name               = "caio-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.environment == "production"

  tags = {
    Name = "caio-${var.environment}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "caio" {
  name        = "caio-${var.environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.caio.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "caio-${var.environment}-tg"
  }
}

# HTTPS Listener
resource "aws_lb_listener" "caio_https" {
  load_balancer_arn = aws_lb.caio.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.caio.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.caio.arn
  }
}

# HTTP to HTTPS Redirect
resource "aws_lb_listener" "caio_http" {
  load_balancer_arn = aws_lb.caio.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ACM Certificate (requires DNS validation)
resource "aws_acm_certificate" "caio" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "caio-${var.environment}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

**File:** `infrastructure/aws/terraform/ecs.tf`

**ECS Configuration:**
```hcl
# ECR Repository
resource "aws_ecr_repository" "caio" {
  name                 = "caio"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "caio-ecr"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "caio" {
  name = "caio-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "caio-${var.environment}-cluster"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "caio" {
  family                   = "caio-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "caio"
      image = "${aws_ecr_repository.caio.repository_url}:${var.caio_image_tag}"

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "CAIO_ENV"
          value = var.environment
        },
        {
          name  = "CAIO_API_HOST"
          value = "0.0.0.0"
        },
        {
          name  = "CAIO_API_PORT"
          value = "8080"
        }
      ]

      secrets = [
        {
          name      = "CAIO_DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:host::"
        },
        {
          name      = "CAIO_DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:dbname::"
        },
        {
          name      = "CAIO_DB_USER"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "CAIO_DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"
        },
        {
          name      = "CAIO_AUTH_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.auth_secret.arn}:secret_key::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.caio.name
          "awslogs-region"         = var.aws_region
          "awslogs-stream-prefix"  = "caio"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "python -c \"import requests; requests.get('http://localhost:8080/health')\""]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 40
      }
    }
  ])

  tags = {
    Name = "caio-${var.environment}-task"
  }
}

# ECS Service
resource "aws_ecs_service" "caio" {
  name            = "caio-${var.environment}-service"
  cluster         = aws_ecs_cluster.caio.id
  task_definition = aws_ecs_task_definition.caio.arn
  desired_count   = var.desired_capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.caio.arn
    container_name   = "caio"
    container_port    = 8080
  }

  depends_on = [
    aws_lb_listener.caio_https,
    aws_iam_role_policy.ecs_task
  ]

  tags = {
    Name = "caio-${var.environment}-service"
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "caio" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.caio.name}/${aws_ecs_service.caio.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "caio_cpu" {
  name               = "caio-${var.environment}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.caio.resource_id
  scalable_dimension = aws_appautoscaling_target.caio.scalable_dimension
  service_namespace  = aws_appautoscaling_target.caio.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_appautoscaling_policy" "caio_memory" {
  name               = "caio-${var.environment}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.caio.resource_id
  scalable_dimension = aws_appautoscaling_target.caio.scalable_dimension
  service_namespace  = aws_appautoscaling_target.caio.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80.0
  }
}
```

**File:** `infrastructure/aws/terraform/rds.tf`

**RDS Configuration:**
```hcl
# DB Subnet Group
resource "aws_db_subnet_group" "caio" {
  name       = "caio-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "caio-${var.environment}-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "caio" {
  identifier             = "caio-${var.environment}-db"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true
  db_name                = "caio"
  username               = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  db_subnet_group_name   = aws_db_subnet_group.caio.name
  vpc_security_group_ids = [aws_security_group.db.id]
  
  multi_az               = var.environment == "production"
  publicly_accessible    = false
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot    = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "caio-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  tags = {
    Name = "caio-${var.environment}-db"
  }
}
```

**File:** `infrastructure/aws/terraform/s3.tf`

**S3 Buckets:**
```hcl
# Artifacts Bucket
resource "aws_s3_bucket" "artifacts" {
  bucket = "caio-${var.environment}-artifacts"

  tags = {
    Name = "caio-${var.environment}-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Backups Bucket
resource "aws_s3_bucket" "backups" {
  bucket = "caio-${var.environment}-backups"

  tags = {
    Name = "caio-${var.environment}-backups"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# Logs Bucket
resource "aws_s3_bucket" "logs" {
  bucket = "caio-${var.environment}-logs"

  tags = {
    Name = "caio-${var.environment}-logs"
  }
}
```

**File:** `infrastructure/aws/terraform/secrets-manager.tf`

**Secrets Manager:**
```hcl
# Database Credentials Secret
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "caio-${var.environment}-db-credentials"

  tags = {
    Name = "caio-${var.environment}-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    host     = aws_db_instance.caio.address
    port     = aws_db_instance.caio.port
    dbname   = aws_db_instance.caio.db_name
    username = "caio_admin"
    password = random_password.db_password.result
  })
}

# Auth Secret Key
resource "aws_secretsmanager_secret" "auth_secret" {
  name = "caio-${var.environment}-auth-secret"

  tags = {
    Name = "caio-${var.environment}-auth-secret"
  }
}

resource "aws_secretsmanager_secret_version" "auth_secret" {
  secret_id = aws_secretsmanager_secret.auth_secret.id
  secret_string = jsonencode({
    secret_key = random_password.auth_secret_key.result
  })
}

# Random Passwords
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "random_password" "auth_secret_key" {
  length  = 64
  special = false
}
```

**File:** `infrastructure/aws/terraform/iam.tf`

**IAM Roles:**
```hcl
# ECS Execution Role
resource "aws_iam_role" "ecs_execution" {
  name = "caio-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "caio-${var.environment}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "caio-${var.environment}-ecs-execution-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_credentials.arn,
          aws_secretsmanager_secret.auth_secret.arn
        ]
      }
    ]
  })
}

# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name = "caio-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "caio-${var.environment}-ecs-task-role"
  }
}

resource "aws_iam_role_policy" "ecs_task" {
  name = "caio-${var.environment}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*",
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*",
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}
```

**File:** `infrastructure/aws/terraform/cloudwatch.tf`

**CloudWatch Configuration:**
```hcl
# Log Group
resource "aws_cloudwatch_log_group" "caio" {
  name              = "/ecs/caio-${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "caio-${var.environment}-logs"
  }
}

# Alarms
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "caio-${var.environment}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when error rate exceeds 10 errors in 5 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = aws_lb.caio.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "caio-${var.environment}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1.0
  alarm_description   = "Alert when P95 latency exceeds 1 second"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = aws_lb.caio.arn_suffix
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "caio-${var.environment}-alerts"

  tags = {
    Name = "caio-${var.environment}-alerts"
  }
}
```

**File:** `infrastructure/aws/terraform/outputs.tf`

**Outputs:**
```hcl
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.caio.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.caio.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.caio.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.caio.repository_url
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.caio.address
  sensitive   = true
}

output "s3_artifacts_bucket" {
  description = "S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}
```

**File:** `infrastructure/aws/terraform/terraform.tfvars.example`

**Example Variables:**
```hcl
aws_region         = "us-east-1"
environment        = "staging"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
caio_image_tag     = "latest"
db_instance_class  = "db.t3.medium"
db_allocated_storage = 100
min_capacity       = 2
max_capacity       = 10
desired_capacity   = 4
domain_name        = "caio.example.com"
```

#### Step 2.2: Create Terraform README

**File:** `infrastructure/aws/terraform/README.md`

**Content:**
```markdown
# CAIO AWS Infrastructure

Terraform configuration for deploying CAIO on AWS.

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. S3 bucket for Terraform state (create manually or use existing)
4. Domain name for ACM certificate (if using HTTPS)

## Setup

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update variables in `terraform.tfvars`
3. Initialize Terraform: `terraform init`
4. Plan deployment: `terraform plan`
5. Apply: `terraform apply`

## Variables

See `variables.tf` for all available variables.

## Outputs

After deployment, outputs include:
- ALB DNS name
- ECS cluster name
- ECR repository URL
- RDS endpoint (sensitive)
- S3 bucket names

## Destroying

To destroy all resources: `terraform destroy`

**WARNING:** This will delete all CAIO infrastructure and data.
```

#### Step 2.3: Validate Terraform Configuration

**Validation Steps:**
```bash
cd infrastructure/aws/terraform
terraform init
terraform validate
terraform fmt -check
terraform plan
```

**Expected Results:**
- `terraform init` succeeds
- `terraform validate` reports no errors
- `terraform fmt -check` reports no formatting issues
- `terraform plan` shows all resources to be created

---

### Task 14.3: Implement Multi-Tenancy Support

**Objective:** Add tenant isolation and resource management to CAIO.

#### Step 3.1: Create Tenant Model

**File:** `caio/models/tenant.py`

**Tenant Model:**
```python
"""Tenant model for multi-tenancy support."""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class Tenant:
    """Represents a CAIO tenant."""
    
    id: str
    name: str
    status: str  # active, suspended, cancelled
    created_at: datetime
    updated_at: datetime
    
    # Resource quotas
    max_services: int = 100
    max_requests_per_minute: int = 1000
    max_requests_per_hour: int = 10000
    max_requests_per_day: int = 100000
    max_storage_bytes: int = 10 * 1024 * 1024 * 1024  # 10 GB
    
    def is_active(self) -> bool:
        """Check if tenant is active."""
        return self.status == "active"
```

#### Step 3.2: Add Tenant Context Middleware

**File:** `caio/api/middleware/tenant.py`

**Tenant Middleware:**
```python
"""Tenant identification middleware."""

from fastapi import Request, HTTPException, status
from typing import Optional
import jwt

from caio.models.tenant import Tenant
from caio.registry.tenant_registry import TenantRegistry


async def get_tenant_from_request(request: Request) -> Optional[Tenant]:
    """Extract tenant from request headers or JWT token."""
    
    # Option 1: X-Tenant-ID header
    tenant_id = request.headers.get("X-Tenant-ID")
    if tenant_id:
        tenant_registry = TenantRegistry()
        tenant = tenant_registry.get_tenant(tenant_id)
        if tenant and tenant.is_active():
            return tenant
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Tenant {tenant_id} not found or inactive"
        )
    
    # Option 2: JWT token
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        token = auth_header.split(" ")[1]
        try:
            # Decode JWT (use your auth secret key)
            payload = jwt.decode(token, options={"verify_signature": False})
            tenant_id = payload.get("tenant_id")
            if tenant_id:
                tenant_registry = TenantRegistry()
                tenant = tenant_registry.get_tenant(tenant_id)
                if tenant and tenant.is_active():
                    return tenant
        except jwt.DecodeError:
            pass
    
    # No tenant identified
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Tenant identification required (X-Tenant-ID header or JWT token)"
    )


def tenant_middleware(request: Request, call_next):
    """FastAPI middleware to extract and validate tenant."""
    tenant = get_tenant_from_request(request)
    request.state.tenant = tenant
    return call_next(request)
```

#### Step 3.3: Update Orchestrator for Multi-Tenancy

**File:** `caio/orchestrator/core.py`

**Modifications:**
```python
# Add tenant parameter to key methods
def register_service(
    self,
    contract_path: str | Path,
    service_id: Optional[str] = None,
    tenant_id: Optional[str] = None,  # ADD THIS
) -> ServiceEntry:
    # Validate tenant exists and is active
    if tenant_id:
        tenant_registry = TenantRegistry()
        tenant = tenant_registry.get_tenant(tenant_id)
        if not tenant or not tenant.is_active():
            raise ValueError(f"Tenant {tenant_id} not found or inactive")
        
        # Check service quota
        existing_services = self.registry.list_services(tenant_id=tenant_id)
        if len(existing_services) >= tenant.max_services:
            raise ValueError(f"Tenant {tenant_id} has reached service limit ({tenant.max_services})")
    
    # ... existing registration logic ...
    # Store tenant_id with service entry
    entry.tenant_id = tenant_id
    return entry

def route_request(
    self,
    request: Request,
    policies: List[Policy],
    history: Optional[Dict] = None,
    seed: Optional[int] = None,
    tenant_id: Optional[str] = None,  # ADD THIS
) -> RoutingDecision:
    # Validate tenant exists and is active
    if tenant_id:
        tenant_registry = TenantRegistry()
        tenant = tenant_registry.get_tenant(tenant_id)
        if not tenant or not tenant.is_active():
            raise ValueError(f"Tenant {tenant_id} not found or inactive")
        
        # Check rate limits
        usage_tracker = TenantUsageTracker()
        if not usage_tracker.check_rate_limit(tenant_id, tenant):
            raise ValueError(f"Tenant {tenant_id} rate limit exceeded")
    
    # Filter services by tenant
    available_services = self.registry.list_services(tenant_id=tenant_id)
    
    # ... existing routing logic ...
    # Store tenant_id in decision
    decision.tenant_id = tenant_id
    return decision
```

#### Step 3.4: Update Service Registry for Tenant Isolation

**File:** `caio/registry/service_registry.py`

**Modifications:**
```python
def list_services(
    self,
    tags: Optional[List[str]] = None,
    tenant_id: Optional[str] = None,  # ADD THIS
) -> List[ServiceEntry]:
    """List services, optionally filtered by tags and tenant."""
    services = self._services.values()
    
    if tenant_id:
        services = [s for s in services if s.tenant_id == tenant_id]
    
    if tags:
        # ... existing tag filtering ...
    
    return list(services)
```

#### Step 3.5: Update Database Schema for Multi-Tenancy

**File:** `caio/database/schema.py` or create migration script

**SQL Migration:**
```sql
-- Add tenant_id columns
ALTER TABLE services ADD COLUMN tenant_id VARCHAR(255);
ALTER TABLE traces ADD COLUMN tenant_id VARCHAR(255);
ALTER TABLE routing_decisions ADD COLUMN tenant_id VARCHAR(255);

-- Create indexes
CREATE INDEX idx_services_tenant_id ON services(tenant_id);
CREATE INDEX idx_traces_tenant_id ON traces(tenant_id);
CREATE INDEX idx_routing_decisions_tenant_id ON routing_decisions(tenant_id);

-- Create tenants table
CREATE TABLE tenants (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    max_services INTEGER DEFAULT 100,
    max_requests_per_minute INTEGER DEFAULT 1000,
    max_requests_per_hour INTEGER DEFAULT 10000,
    max_requests_per_day INTEGER DEFAULT 100000,
    max_storage_bytes BIGINT DEFAULT 10737418240,  -- 10 GB
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create tenant_usage table
CREATE TABLE tenant_usage (
    tenant_id VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    api_calls INTEGER DEFAULT 0,
    compute_seconds DECIMAL(10,2) DEFAULT 0,
    storage_bytes BIGINT DEFAULT 0,
    PRIMARY KEY (tenant_id, date),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

-- Create tenant_rate_limits table (for per-minute/hour tracking)
CREATE TABLE tenant_rate_limits (
    tenant_id VARCHAR(255) NOT NULL,
    window_type VARCHAR(20) NOT NULL,  -- minute, hour, day
    window_start TIMESTAMP NOT NULL,
    request_count INTEGER DEFAULT 0,
    PRIMARY KEY (tenant_id, window_type, window_start)
);
```

#### Step 3.6: Create Tenant Registry

**File:** `caio/registry/tenant_registry.py`

**Tenant Registry:**
```python
"""Tenant registry for managing CAIO tenants."""

from typing import Optional, List
from caio.models.tenant import Tenant
from caio.database.connection import get_db_connection


class TenantRegistry:
    """Registry for managing CAIO tenants."""
    
    def __init__(self):
        self._cache = {}
    
    def get_tenant(self, tenant_id: str) -> Optional[Tenant]:
        """Get tenant by ID."""
        # Check cache first
        if tenant_id in self._cache:
            return self._cache[tenant_id]
        
        # Query database
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, name, status, max_services, max_requests_per_minute, "
            "max_requests_per_hour, max_requests_per_day, max_storage_bytes, "
            "created_at, updated_at FROM tenants WHERE id = ?",
            (tenant_id,)
        )
        row = cursor.fetchone()
        cursor.close()
        
        if row:
            tenant = Tenant(
                id=row[0],
                name=row[1],
                status=row[2],
                max_services=row[3],
                max_requests_per_minute=row[4],
                max_requests_per_hour=row[5],
                max_requests_per_day=row[6],
                max_storage_bytes=row[7],
                created_at=row[8],
                updated_at=row[9],
            )
            self._cache[tenant_id] = tenant
            return tenant
        
        return None
    
    def list_tenants(self, status: Optional[str] = None) -> List[Tenant]:
        """List all tenants, optionally filtered by status."""
        conn = get_db_connection()
        cursor = conn.cursor()
        
        if status:
            cursor.execute(
                "SELECT id, name, status, max_services, max_requests_per_minute, "
                "max_requests_per_hour, max_requests_per_day, max_storage_bytes, "
                "created_at, updated_at FROM tenants WHERE status = ?",
                (status,)
            )
        else:
            cursor.execute(
                "SELECT id, name, status, max_services, max_requests_per_minute, "
                "max_requests_per_hour, max_requests_per_day, max_storage_bytes, "
                "created_at, updated_at FROM tenants"
            )
        
        rows = cursor.fetchall()
        cursor.close()
        
        tenants = []
        for row in rows:
            tenant = Tenant(
                id=row[0],
                name=row[1],
                status=row[2],
                max_services=row[3],
                max_requests_per_minute=row[4],
                max_requests_per_hour=row[5],
                max_requests_per_day=row[6],
                max_storage_bytes=row[7],
                created_at=row[8],
                updated_at=row[9],
            )
            tenants.append(tenant)
            self._cache[tenant.id] = tenant
        
        return tenants
```

#### Step 3.7: Create Usage Tracker

**File:** `caio/usage/tracker.py`

**Usage Tracker:**
```python
"""Track tenant usage and enforce rate limits."""

from datetime import datetime, timedelta
from typing import Optional
from caio.models.tenant import Tenant
from caio.database.connection import get_db_connection


class TenantUsageTracker:
    """Track and enforce tenant usage quotas."""
    
    def check_rate_limit(self, tenant_id: str, tenant: Tenant) -> bool:
        """Check if tenant is within rate limits."""
        now = datetime.utcnow()
        
        # Check per-minute limit
        minute_start = now.replace(second=0, microsecond=0)
        minute_count = self._get_request_count(tenant_id, "minute", minute_start)
        if minute_count >= tenant.max_requests_per_minute:
            return False
        
        # Check per-hour limit
        hour_start = now.replace(minute=0, second=0, microsecond=0)
        hour_count = self._get_request_count(tenant_id, "hour", hour_start)
        if hour_count >= tenant.max_requests_per_hour:
            return False
        
        # Check per-day limit
        day_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        day_count = self._get_request_count(tenant_id, "day", day_start)
        if day_count >= tenant.max_requests_per_day:
            return False
        
        return True
    
    def record_request(self, tenant_id: str) -> None:
        """Record a request for tenant usage tracking."""
        now = datetime.utcnow()
        
        # Update per-minute window
        minute_start = now.replace(second=0, microsecond=0)
        self._increment_request_count(tenant_id, "minute", minute_start)
        
        # Update per-hour window
        hour_start = now.replace(minute=0, second=0, microsecond=0)
        self._increment_request_count(tenant_id, "hour", hour_start)
        
        # Update per-day window
        day_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        self._increment_request_count(tenant_id, "day", day_start)
        
        # Update daily usage table
        self._update_daily_usage(tenant_id, now.date())
    
    def _get_request_count(
        self, tenant_id: str, window_type: str, window_start: datetime
    ) -> int:
        """Get request count for a time window."""
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT request_count FROM tenant_rate_limits "
            "WHERE tenant_id = ? AND window_type = ? AND window_start = ?",
            (tenant_id, window_type, window_start)
        )
        row = cursor.fetchone()
        cursor.close()
        return row[0] if row else 0
    
    def _increment_request_count(
        self, tenant_id: str, window_type: str, window_start: datetime
    ) -> None:
        """Increment request count for a time window."""
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO tenant_rate_limits (tenant_id, window_type, window_start, request_count) "
            "VALUES (?, ?, ?, 1) "
            "ON CONFLICT(tenant_id, window_type, window_start) "
            "DO UPDATE SET request_count = request_count + 1",
            (tenant_id, window_type, window_start)
        )
        conn.commit()
        cursor.close()
    
    def _update_daily_usage(self, tenant_id: str, date: datetime.date) -> None:
        """Update daily usage statistics."""
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO tenant_usage (tenant_id, date, api_calls) "
            "VALUES (?, ?, 1) "
            "ON CONFLICT(tenant_id, date) "
            "DO UPDATE SET api_calls = api_calls + 1",
            (tenant_id, date)
        )
        conn.commit()
        cursor.close()
```

#### Step 3.8: Update API Routes for Tenant Context

**File:** `caio/api/routes/orchestrate.py`

**Modifications:**
```python
@api_router.post("/orchestrate", response_model=OrchestrateResponse)
async def orchestrate_endpoint(
    request: OrchestrateRequest,
    orchestrator: Orchestrator = Depends(get_orchestrator),
    _actor=Depends(require_roles("admin", "service", "user")),
    tenant: Tenant = Depends(get_tenant_from_request),  # ADD THIS
):
    # Extract tenant_id from request state (set by middleware)
    tenant_id = tenant.id if tenant else None
    
    # Record usage
    usage_tracker = TenantUsageTracker()
    usage_tracker.record_request(tenant_id)
    
    result = orchestrate_request(
        request_data=request.request,
        policies=request.policies,
        context=request.context,
        orchestrator=orchestrator,
        tenant_id=tenant_id,  # PASS TENANT_ID
    )
    return OrchestrateResponse(**result)
```

#### Step 3.9: Add Tenant Management API Endpoints

**File:** `caio/api/routes/tenants.py`

**Tenant Management API:**
```python
"""Tenant management API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from pydantic import BaseModel

from caio.registry.tenant_registry import TenantRegistry
from caio.models.tenant import Tenant
from caio.api.auth import require_roles


api_router = APIRouter(prefix="/api/v1/tenants", tags=["Tenants"])


class TenantResponse(BaseModel):
    id: str
    name: str
    status: str
    max_services: int
    max_requests_per_minute: int
    max_requests_per_hour: int
    max_requests_per_day: int
    max_storage_bytes: int


@api_router.get("/", response_model=List[TenantResponse])
async def list_tenants(
    status: Optional[str] = None,
    tenant_registry: TenantRegistry = Depends(lambda: TenantRegistry()),
    _actor=Depends(require_roles("admin")),
):
    """List all tenants."""
    tenants = tenant_registry.list_tenants(status=status)
    return [
        TenantResponse(
            id=t.id,
            name=t.name,
            status=t.status,
            max_services=t.max_services,
            max_requests_per_minute=t.max_requests_per_minute,
            max_requests_per_hour=t.max_requests_per_hour,
            max_requests_per_day=t.max_requests_per_day,
            max_storage_bytes=t.max_storage_bytes,
        )
        for t in tenants
    ]


@api_router.get("/{tenant_id}", response_model=TenantResponse)
async def get_tenant(
    tenant_id: str,
    tenant_registry: TenantRegistry = Depends(lambda: TenantRegistry()),
    _actor=Depends(require_roles("admin")),
):
    """Get tenant by ID."""
    tenant = tenant_registry.get_tenant(tenant_id)
    if not tenant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tenant {tenant_id} not found"
        )
    return TenantResponse(
        id=tenant.id,
        name=tenant.name,
        status=tenant.status,
        max_services=tenant.max_services,
        max_requests_per_minute=tenant.max_requests_per_minute,
        max_requests_per_hour=tenant.max_requests_per_hour,
        max_requests_per_day=tenant.max_requests_per_day,
        max_storage_bytes=tenant.max_storage_bytes,
    )
```

#### Step 3.10: Testing Multi-Tenancy

**File:** `tests/integration/test_multi_tenancy.py`

**Test Cases:**
```python
"""Integration tests for multi-tenancy."""

import pytest
from caio import Orchestrator
from caio.registry.tenant_registry import TenantRegistry
from caio.models.tenant import Tenant


def test_tenant_isolation():
    """Test that tenants cannot access each other's services."""
    orchestrator = Orchestrator()
    tenant_registry = TenantRegistry()
    
    # Create two tenants
    tenant1 = Tenant(id="tenant-1", name="Tenant 1", status="active")
    tenant2 = Tenant(id="tenant-2", name="Tenant 2", status="active")
    tenant_registry.create_tenant(tenant1)
    tenant_registry.create_tenant(tenant2)
    
    # Register service for tenant 1
    service1 = orchestrator.register_service(
        contract_path="configs/services/tenant1-service.yaml",
        tenant_id="tenant-1"
    )
    
    # Register service for tenant 2
    service2 = orchestrator.register_service(
        contract_path="configs/services/tenant2-service.yaml",
        tenant_id="tenant-2"
    )
    
    # Tenant 1 should only see their service
    services_t1 = orchestrator.list_services(tenant_id="tenant-1")
    assert len(services_t1) == 1
    assert services_t1[0].contract.service_id == service1.contract.service_id
    
    # Tenant 2 should only see their service
    services_t2 = orchestrator.list_services(tenant_id="tenant-2")
    assert len(services_t2) == 1
    assert services_t2[0].contract.service_id == service2.contract.service_id


def test_rate_limiting():
    """Test that rate limits are enforced per tenant."""
    # ... test rate limiting ...
    pass


def test_service_quota():
    """Test that service quotas are enforced per tenant."""
    # ... test service quotas ...
    pass
```

**Validation:**
- Multi-tenancy tests pass
- No cross-tenant data access
- Rate limits enforced correctly
- Service quotas enforced correctly

---

### Task 14.4: Containerize CAIO Application

**Objective:** Create Docker container for CAIO deployment.

#### Step 4.1: Create Dockerfile

**File:** `Dockerfile`

**Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy CAIO source code
COPY caio/ ./caio/
COPY pyproject.toml .

# Install CAIO package
RUN pip install -e .

# Create non-root user
RUN useradd -m -u 1000 caio && chown -R caio:caio /app
USER caio

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8080/health')"

# Run CAIO API
CMD ["uvicorn", "caio.api.app:app", "--host", "0.0.0.0", "--port", "8080"]
```

#### Step 4.2: Create .dockerignore

**File:** `.dockerignore`

**Content:**
```
.git
.gitignore
.cursor
.vscode
__pycache__
*.pyc
*.pyo
*.pyd
.Python
*.so
*.egg
*.egg-info
dist
build
.venv
venv
env
.env
*.log
*.db
*.sqlite
notebooks/
tests/
docs/
infrastructure/
plans/
*.md
!README.md
```

#### Step 4.3: Create docker-compose.yml for Local Testing

**File:** `docker-compose.yml`

**Content:**
```yaml
version: '3.8'

services:
  caio:
    build: .
    ports:
      - "8080:8080"
    environment:
      - CAIO_ENV=development
      - CAIO_API_HOST=0.0.0.0
      - CAIO_API_PORT=8080
      - CAIO_DB_HOST=postgres
      - CAIO_DB_NAME=caio
      - CAIO_DB_USER=caio
      - CAIO_DB_PASSWORD=caio_password
      - CAIO_AUTH_SECRET_KEY=dev-secret-key-change-in-production
    depends_on:
      - postgres
    healthcheck:
      test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8080/health')"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=caio
      - POSTGRES_USER=caio
      - POSTGRES_PASSWORD=caio_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U caio"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

#### Step 4.4: Validate Docker Build

**Validation Steps:**
```bash
# Build Docker image
docker build -t caio:latest .

# Test locally with docker-compose
docker-compose up -d

# Verify health check
curl http://localhost:8080/health

# Test API endpoints
curl http://localhost:8080/api/v1/orchestrate -X POST -H "Content-Type: application/json" -d '{"request": {...}}'

# Stop
docker-compose down
```

**Expected Results:**
- Docker image builds successfully
- Container runs and health check passes
- CAIO API endpoints respond correctly
- Database connection works

---

### Task 14.5: Create CI/CD Pipeline

**Objective:** Automate deployment to AWS staging and production.

#### Step 5.1: Create GitHub Actions Workflow

**File:** `.github/workflows/deploy-aws.yml`

**Workflow:**
```yaml
name: Deploy CAIO to AWS

on:
  push:
    branches: [main, staging]
  workflow_dispatch:

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: caio

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT
      
      - name: Run tests
        run: |
          docker run --rm ${{ steps.build-image.outputs.image }} pytest tests/
      
      - name: Run linting
        run: |
          docker run --rm ${{ steps.build-image.outputs.image }} make lint-all

  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/staging'
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        working-directory: infrastructure/aws/terraform
        run: terraform init
      
      - name: Terraform Plan
        working-directory: infrastructure/aws/terraform
        run: terraform plan -var="environment=staging" -var="caio_image_tag=${{ github.sha }}"
      
      - name: Terraform Apply
        working-directory: infrastructure/aws/terraform
        run: terraform apply -auto-approve -var="environment=staging" -var="caio_image_tag=${{ github.sha }}"
      
      - name: Update ECS Service
        run: |
          aws ecs update-service \
            --cluster caio-staging-cluster \
            --service caio-staging-service \
            --force-new-deployment \
            --region ${{ env.AWS_REGION }}
      
      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster caio-staging-cluster \
            --services caio-staging-service \
            --region ${{ env.AWS_REGION }}
      
      - name: Run smoke tests
        run: |
          ALB_DNS=$(terraform output -raw alb_dns_name -state=infrastructure/aws/terraform/terraform.tfstate)
          curl -f https://$ALB_DNS/health || exit 1

  deploy-production:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        working-directory: infrastructure/aws/terraform
        run: terraform init
      
      - name: Terraform Plan
        working-directory: infrastructure/aws/terraform
        run: terraform plan -var="environment=production" -var="caio_image_tag=${{ github.sha }}"
      
      - name: Terraform Apply
        working-directory: infrastructure/aws/terraform
        run: terraform apply -auto-approve -var="environment=production" -var="caio_image_tag=${{ github.sha }}"
      
      - name: Update ECS Service
        run: |
          aws ecs update-service \
            --cluster caio-production-cluster \
            --service caio-production-service \
            --force-new-deployment \
            --region ${{ env.AWS_REGION }}
      
      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster caio-production-cluster \
            --services caio-production-service \
            --region ${{ env.AWS_REGION }}
      
      - name: Run smoke tests
        run: |
          ALB_DNS=$(terraform output -raw alb_dns_name -state=infrastructure/aws/terraform/terraform.tfstate)
          curl -f https://$ALB_DNS/health || exit 1
```

#### Step 5.2: Configure GitHub Secrets

**Required Secrets:**
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

**Setup:**
1. Create IAM user in AWS with appropriate permissions
2. Generate access keys
3. Add secrets to GitHub repository settings

#### Step 5.3: Test CI/CD Pipeline

**Validation Steps:**
1. Push to `staging` branch
2. Verify workflow runs
3. Verify deployment to staging succeeds
4. Verify smoke tests pass
5. Push to `main` branch (requires approval)
6. Verify production deployment

**Expected Results:**
- Pipeline runs successfully
- Docker image built and pushed to ECR
- Terraform applies infrastructure changes
- ECS service updates with new image
- Health checks pass
- Smoke tests pass

---

### Task 14.6: Configure Monitoring & Alerting

**Objective:** Set up CloudWatch monitoring, metrics, and alerts.

#### Step 6.1: Add CloudWatch Logging to CAIO

**File:** `caio/api/middleware/logging.py`

**CloudWatch Logging:**
```python
"""CloudWatch logging middleware."""

import json
import logging
from datetime import datetime
from fastapi import Request
import boto3

from caio.config import CAIOConfig


class CloudWatchLogger:
    """Logger that sends logs to CloudWatch."""
    
    def __init__(self, log_group_name: str, region: str = "us-east-1"):
        self.log_group_name = log_group_name
        self.client = boto3.client("logs", region_name=region)
        self._ensure_log_group()
    
    def _ensure_log_group(self):
        """Ensure CloudWatch log group exists."""
        try:
            self.client.create_log_group(logGroupName=self.log_group_name)
        except self.client.exceptions.ResourceAlreadyExistsException:
            pass
    
    def log(self, message: str, level: str = "INFO", **kwargs):
        """Log message to CloudWatch."""
        log_stream_name = f"caio-{datetime.utcnow().strftime('%Y-%m-%d')}"
        
        try:
            self.client.create_log_stream(
                logGroupName=self.log_group_name,
                logStreamName=log_stream_name
            )
        except self.client.exceptions.ResourceAlreadyExistsException:
            pass
        
        log_event = {
            "timestamp": int(datetime.utcnow().timestamp() * 1000),
            "message": json.dumps({
                "level": level,
                "message": message,
                **kwargs
            })
        }
        
        self.client.put_log_events(
            logGroupName=self.log_group_name,
            logStreamName=log_stream_name,
            logEvents=[log_event]
        )
```

#### Step 6.2: Add Custom Metrics to CAIO

**File:** `caio/metrics/cloudwatch.py`

**CloudWatch Metrics:**
```python
"""CloudWatch metrics exporter."""

import boto3
from datetime import datetime
from typing import Dict, Optional


class CloudWatchMetrics:
    """Export custom metrics to CloudWatch."""
    
    def __init__(self, namespace: str = "CAIO", region: str = "us-east-1"):
        self.namespace = namespace
        self.client = boto3.client("cloudwatch", region_name=region)
    
    def put_metric(
        self,
        metric_name: str,
        value: float,
        unit: str = "Count",
        dimensions: Optional[Dict[str, str]] = None,
    ):
        """Put a custom metric to CloudWatch."""
        metric_data = {
            "MetricName": metric_name,
            "Value": value,
            "Unit": unit,
            "Timestamp": datetime.utcnow(),
        }
        
        if dimensions:
            metric_data["Dimensions"] = [
                {"Name": k, "Value": v} for k, v in dimensions.items()
            ]
        
        self.client.put_metric_data(
            Namespace=self.namespace,
            MetricData=[metric_data]
        )
    
    def record_orchestration_request(self, tenant_id: Optional[str] = None):
        """Record an orchestration request."""
        dimensions = {}
        if tenant_id:
            dimensions["TenantID"] = tenant_id
        self.put_metric("OrchestrationRequests", 1.0, "Count", dimensions)
    
    def record_routing_latency(
        self, latency_ms: float, tenant_id: Optional[str] = None
    ):
        """Record routing decision latency."""
        dimensions = {}
        if tenant_id:
            dimensions["TenantID"] = tenant_id
        self.put_metric("RoutingLatency", latency_ms, "Milliseconds", dimensions)
    
    def record_service_count(self, count: int, tenant_id: Optional[str] = None):
        """Record service registry size."""
        dimensions = {}
        if tenant_id:
            dimensions["TenantID"] = tenant_id
        self.put_metric("ServiceCount", count, "Count", dimensions)
```

#### Step 6.3: Integrate Metrics into Orchestrator

**File:** `caio/orchestrator/core.py`

**Add Metrics:**
```python
from caio.metrics.cloudwatch import CloudWatchMetrics

class Orchestrator:
    def __init__(self, ...):
        # ... existing initialization ...
        self.metrics = CloudWatchMetrics()
    
    def route_request(self, ...):
        start_time = time.time()
        # ... existing routing logic ...
        latency_ms = (time.time() - start_time) * 1000
        
        # Record metrics
        self.metrics.record_orchestration_request(tenant_id=tenant_id)
        self.metrics.record_routing_latency(latency_ms, tenant_id=tenant_id)
        self.metrics.record_service_count(
            len(available_services), tenant_id=tenant_id
        )
        
        return decision
```

#### Step 6.4: Create CloudWatch Dashboards

**File:** `infrastructure/aws/terraform/cloudwatch-dashboards.tf`

**Dashboard Configuration:**
```hcl
resource "aws_cloudwatch_dashboard" "caio_overview" {
  dashboard_name = "caio-${var.environment}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", {"stat": "Sum"}],
            [".", "HTTPCode_Target_5XX_Count", {"stat": "Sum"}],
            [".", "TargetResponseTime", {"stat": "Average"}]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "CAIO Overview"
          period  = 300
        }
      }
    ]
  })
}
```

**Validation:**
- CloudWatch logs appear in log groups
- Custom metrics visible in CloudWatch
- Alarms configured and tested
- Dashboards display accurate data

---

### Task 14.7: Create Deployment Documentation

**Objective:** Document AWS deployment process, architecture, and operations.

#### Step 7.1: Create AWS Deployment Guide

**File:** `docs/deployment/AWS_DEPLOYMENT.md`

**Sections:**
1. Prerequisites
2. Infrastructure Setup
3. Application Deployment
4. Configuration
5. Scaling and Capacity Planning
6. Cost Optimization
7. Troubleshooting

**Content:** (Detailed step-by-step instructions)

#### Step 7.2: Create Architecture Documentation

**File:** `docs/deployment/AWS_ARCHITECTURE.md`

**Content:**
- Architecture diagram
- Component descriptions
- Network topology
- Security model
- Data flow

#### Step 7.3: Create Cost Estimation Guide

**File:** `docs/deployment/COST_ESTIMATION.md`

**Content:**
- Cost breakdown by AWS service
- Monthly cost estimates (small, medium, large)
- Cost optimization recommendations
- Reserved instance recommendations

**Validation:**
- Documentation is complete and accurate
- All commands work as documented
- Diagrams are clear and accurate

---

## Validation Procedures

### Infrastructure Validation

**Commands:**
```bash
cd infrastructure/aws/terraform
terraform init
terraform validate
terraform plan
terraform apply
```

**Expected Results:**
- All resources created successfully
- No errors in Terraform output
- All resources tagged correctly

### Application Validation

**Commands:**
```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Health check
curl https://$ALB_DNS/health

# API test
curl https://$ALB_DNS/api/v1/orchestrate \
  -X POST \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: test-tenant" \
  -d '{"request": {...}}'
```

**Expected Results:**
- Health check returns 200 OK
- API endpoints respond correctly
- Multi-tenancy working (tenant isolation)

### Multi-Tenancy Validation

**Test Cases:**
1. Register service for tenant-1
2. Register service for tenant-2
3. List services for tenant-1 (should only see tenant-1 services)
4. List services for tenant-2 (should only see tenant-2 services)
5. Verify no cross-tenant access

### CI/CD Validation

**Test:**
1. Push to staging branch
2. Verify workflow runs
3. Verify deployment succeeds
4. Verify smoke tests pass

---

## Troubleshooting Guide

### Common Issues

1. **Terraform State Lock:**
   - Issue: State file locked
   - Solution: Check for running Terraform processes, unlock if needed

2. **ECS Service Not Starting:**
   - Issue: Tasks failing to start
   - Solution: Check CloudWatch logs, verify secrets, check IAM roles

3. **Database Connection Failures:**
   - Issue: Cannot connect to RDS
   - Solution: Check security groups, verify credentials in Secrets Manager

4. **ALB Health Check Failures:**
   - Issue: Health checks failing
   - Solution: Verify application is running, check health endpoint

5. **High Costs:**
   - Issue: AWS costs higher than expected
   - Solution: Review resource sizes, use reserved instances, optimize auto-scaling

---

## Success Criteria

**Infrastructure:**
- [ ] All AWS resources created successfully
- [ ] CAIO application running in AWS
- [ ] Health checks passing
- [ ] HTTPS/TLS working

**Multi-Tenancy:**
- [ ] Tenant isolation working correctly
- [ ] No cross-tenant data access
- [ ] Resource quotas enforced
- [ ] Usage tracking accurate

**CI/CD:**
- [ ] Pipeline deploys to staging automatically
- [ ] Production deployment requires approval
- [ ] Rollback procedure tested and working

**Monitoring:**
- [ ] CloudWatch metrics visible
- [ ] Alarms configured and tested
- [ ] Dashboards show accurate data
- [ ] Logs aggregated correctly

**Documentation:**
- [ ] Deployment guide complete
- [ ] Architecture diagram accurate
- [ ] Cost estimates provided
- [ ] Troubleshooting guide complete

---

## Notes and References

- **AWS Well-Architected Framework:** https://aws.amazon.com/architecture/well-architected/
- **Terraform AWS Provider:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **ECS Best Practices:** https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/
- **RDS Best Practices:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
- **CloudWatch Best Practices:** https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_best_practices.html

---

**Last Updated:** 2026-01-12
**Version:** 1.0
