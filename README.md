# ☸️ EKS-Cluster

![Version](https://img.shields.io/github/v/tag/grevyrincon/eks-cluster?label=version)


This repository contains the **Helm chart** and **Jenkins pipeline** used to deploy an application stack on **Amazon EKS (Elastic Kubernetes Service)**.  
It includes deployment manifests for the API service and MongoDB, all managed through a customizable Helm chart.

---

## 📁 Project Structure

```bash
.
├── CHANGELOG.md              # Version history and release notes
├── Jenkinsfile               # CI/CD pipeline for EKS deployment
├── README.md                 # Project documentation
└── helm-chart/               # Helm chart for application deployment
    ├── Chart.yaml            # Chart metadata (name, version, description)
    ├── templates/            # Kubernetes manifests templated for Helm
    │   ├── _helpers.tpl
    │   ├── api-deployment.yaml
    │   ├── api-service.yaml
    │   ├── mongo-deployment.yaml
    │   └── mongo-service.yaml
    └── values.yaml           # Default Helm configuration values

```

## Changelog

See CHANGELOG.md for version details and update history.