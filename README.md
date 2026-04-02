## End-to-End CI/CD Pipeline with Docker & Amazon ECS

**Tech Stack:** Git, GitHub, Jenkins, Maven, Docker, ECR, ECS (Fargate), Terraform

### Key Implementation

- Designed a CI/CD pipeline using Jenkins to automate build, test, Docker image creation, and deployment to Amazon ECS.  
- Containerized a Spring Boot application using Docker and pushed images to Amazon ECR.  
- Provisioned ECS infrastructure using Terraform with reusable configurations.  
- Implemented deployment health checks with timeout-based validation and automated rollback on failure.  