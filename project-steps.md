## ⚙️ Step-by-Step Implementation

### Application Development
- Created a Spring Boot application with REST endpoints: `/health`, `/version`, and `/users`.  
- Implemented `/health` for service status validation.  
- Implemented `/version` to return application version dynamically using environment variables.  
- Added basic `/users` API for GET and POST operations to simulate real application behavior.  

---

### Maven Build Setup
- Configured `pom.xml` with required dependencies (Spring Boot Web, Actuator).  
- Enabled packaging of the application as a JAR file.  
- Verified build using Maven (`mvn clean package`).  

---

### Dockerization
- Created a multi-stage `Dockerfile`:  
  - Stage 1: Build using Maven image  
  - Stage 2: Lightweight runtime using OpenJDK  
- Passed application version as a build argument.  
- Built Docker image and verified container locally.  

---

### Jenkins Pipeline Setup
- Created Jenkins pipeline with stages:  
  - Build & Test  
  - Docker Build  
  - Docker Push to ECR  
  - Deploy to ECS  
  - Health Check  
- Automated version tagging using build number.  
- Configured AWS CLI within Jenkins for deployment.  

---

### Amazon ECR Setup
- Created ECR repository for storing Docker images.  
- Configured authentication from Jenkins to push images securely.  
- Verified image versions with incremental tags.  

---

### ECS (Fargate) Configuration
- Created ECS cluster using Fargate launch type.  
- Defined task definition with container image, CPU, memory, and port mapping.  
- Configured service to maintain desired task count.  
- Enabled public IP assignment for external access.  

---

### IAM Roles & Permissions
- Created ECS task execution role.  
- Attached `AmazonECSTaskExecutionRolePolicy` for ECR access.  
- Configured Jenkins EC2 role with ECR and ECS permissions for deployment.  

---

### Terraform Infrastructure
- Defined ECS cluster, task definition, service, IAM roles, and networking in Terraform.  
- Used reusable configurations for infrastructure setup.  
- Applied changes using `terraform apply`.  

---

### Deployment Strategy
- Implemented rolling deployments via ECS service updates.  
- Registered new task definitions with updated image versions.  
- Ensured zero-downtime deployment by replacing old tasks gradually.  

---

### Health Check & Validation
- Added Jenkins stage to wait for ECS service stabilization.  
- Implemented timeout-based validation (e.g., 240 seconds).  
- Verified running task count and application health endpoint.  

---

### Rollback Testing
- Simulated failure scenarios by breaking application health endpoint.  
- Observed ECS failing to stabilize.  
- Triggered rollback to previous stable task definition.  

---

### API Testing
- Accessed application via public IP and tested endpoints:  
  - `/health` → service status  
  - `/version` → deployed version  
  - `/users` → API functionality  
- Verified successful deployment and version updates after each pipeline run.  

---

## ✅ Final Outcome

- Fully automated CI/CD pipeline from code to deployment.  
- Dockerized application deployed on ECS Fargate.  
- Version-controlled deployments using ECR image tagging.  
- Reliable deployments with health checks and rollback mechanism.  
- Infrastructure managed using Terraform for repeatability and scalability.  