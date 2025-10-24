pipeline {
  agent any

  environment {      
    ENV = "prod"
    CHART_DIR = "helm-chart"
    AWS_REGION = 'us-east-1'
    TF_BUCKET = "terraform-state-bucket-eks-cluster"  
    TF_KEY = "${ENV}/terraform.tfstate"  
    PYTHON_APP_BRANCH = "main"
    SECRET_NAME = 'aws-cred'
  }

  stages {
    stage('Checkout') {
      steps {
        dir('python-app') {
          script {
              // Full clone with tags
              checkout([$class: 'GitSCM',
                  branches: [[name: "*/${PYTHON_APP_BRANCH}"]],
                  doGenerateSubmoduleConfigurations: false,
                  extensions: [[$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: false]],
                  userRemoteConfigs: [[url: 'https://github.com/grevyrincon/python-app.git']]]
              )
              env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          }
        }
      }
    }

    stage('Load Environment from Terraform State') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: "${SECRET_NAME}") {
          script {
              // Download the tfstate file
              sh "aws s3 cp s3://${TF_BUCKET}/${TF_KEY} ./terraform.tfstate"

              // Read the state file JSON
              def tfStateText = readFile('terraform.tfstate')
              def tfState = readJSON text: tfStateText
              def outputs = tfState.outputs

              env.KUBE_CLUSTER = outputs.cluster_name.value
              env.ECR_REGISTRY = outputs.ecr_repository_url.value
              env.AWS_REGION = outputs.aws_region.value
              def sanitizedBranchName = BRANCH_NAME.replaceAll('[^a-zA-Z0-9-]', '-')
              env.HELM_RELEASE = sanitizedBranchName
              env.K8S_NAMESPACE = sanitizedBranchName

          }
        }
      }
    }
    stage('Deploy to EKS via Helm') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: "${SECRET_NAME}") {
          sh """
            aws eks update-kubeconfig --region ${AWS_REGION} --name ${KUBE_CLUSTER}
            ls -la 

            cd ${CHART_DIR}
            helm upgrade --install ${HELM_RELEASE} . \\
              -f values.yaml \\
              --namespace ${K8S_NAMESPACE} \\
              --create-namespace \\
              --set image.repository=${ECR_REGISTRY} \\
              --set image.tag=${IMAGE_TAG}
          """
        }
      }
    }
    
    
    
  }

  post {
    success {
      echo "Deploy successful"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
