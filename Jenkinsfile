pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
    }

    stages {

        stage('Checkout Repo') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/yash2801murani/Automation_LIveStream_AWS_CICD_TF.git'
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
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Show Outputs') {
            steps {
                sh 'terraform output'
            }
        }

          stage('Share Credentials to admin') {
            steps {
                echo 'Send email successfully to yash.murani0@gmail.com'
            }
        }
    }
}
