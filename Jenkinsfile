pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-1"           
    ECR_REGISTRY =  "463470979148.dkr.ecr.us-east-1.amazonaws.com"
    ECR_REPO = "python-api-repo"
    IMAGE_TAG = "deploy"
    CHART_DIR = "helm-chart"
    KUBE_CLUSTER   = "api-cluster"
    HELM_RELEASE   = "python-api"
    K8S_NAMESPACE  = "default"
  }

  stages {
    stage('Login to ECR') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'aws-cred') {
          sh '''
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
          '''
        }
      }
    }
    stage('Build Docker image') {
      steps {
        sh "docker build -t ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG} ./app"
      }
    }

    stage('Push to ECR') {
      steps {
        sh "docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
      }
    }
    stage('Validate AWS') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'aws-cred') {
          sh 'aws --version'
          sh 'aws sts get-caller-identity'
          sh 'aws eks list-clusters'
        }
      }
    }

    stage('Deploy to EKS via Helm') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'aws-cred') {
          sh """
            aws eks update-kubeconfig --region ${AWS_REGION} --name ${KUBE_CLUSTER}

            helm upgrade --install ${HELM_RELEASE} ${CHART_DIR} \\
              -f ${CHART_DIR}/values.yaml \\
              --namespace ${K8S_NAMESPACE} \\
              --set image.repository=${ECR_REGISTRY}/${ECR_REPO} \\
              --set image.tag=${IMAGE_TAG}
          """
        }
      }
    }
    
  }

  post {
    success {
      echo "Deploy successful: ${ECR_REPO}:${IMAGE_TAG}"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
