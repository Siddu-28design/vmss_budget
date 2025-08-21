pipeline {
    agent any

    environment {
	ARM_CLIENT_ID        = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET    = credentials('ARM_CLIENT_SECRET')
        ARM_TENANT_ID        = credentials('ARM_TENANT_ID')
        ARM_SUBSCRIPTION_ID  = credentials('ARM_SUBSCRIPTION_ID')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Siddu-28design/vmss_budget.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        } 
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Wait before Destroy') {
            steps {
                echo 'Waiting 30 minutes before destroying resources...'
                sleep(time: 30, unit: 'MINUTES')  
            }
        }

        stage('Terraform Destroy') {
            steps {
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}
