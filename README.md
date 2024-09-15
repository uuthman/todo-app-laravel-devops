## Web Application Deployment on AWS EKS using AWS EKS, ALB Ingress Controller,ArgoCD,Terraform and Github Action

This project is a Todo application built using Laravel, Vue.js, and Tailwind CSS.

### Screenshots

![Architecture Diagram](/docs/screenshots/arch.png)

 Welcome to the Web Application Deployment project! 🚀

This repository hosts the implementation of a Two-Tier Web App using Vue, Laravel, and Postgres, deployed on AWS EKS. The project covers a wide range of tools and practices for a robust and scalable DevOps setup.


### Project Details 

#### 🛠️ Tools Explored:
- Terraform & AWS CLI for AWS infrastructure
- Github Action, Terraform, Kubectl, and more for CI/CD setup
- Helm
- ArgoCD for GitOps practices

#### Infra set up
A GitHub Actions file has been created to provision infrastructure on AWS, and it can be triggered manually from the Actions page.

#### Code deployment 
A GitHub Actions file has been created deploy the code to docker hub and update the tag on helm value, and it can be triggered on push to the main branch 


### License

This project is licensed under the [MIT License](LICENSE.md). Feel free to use and modify the code as per your requirements.
