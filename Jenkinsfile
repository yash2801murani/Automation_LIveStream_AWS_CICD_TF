
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
        dir('.') {
          sh 'terraform init -input=false'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('.') {
          sh 'terraform plan -out=tfplan -input=false'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('.') {
          sh 'terraform apply -auto-approve -input=false tfplan'
        }
      }
    }

    stage('Read Outputs') {
      steps {
        script {
          PLAYBACK = sh(script: "terraform output -raw ivs_playback_url", returnStdout: true).trim()
          INGEST   = sh(script: "terraform output -raw ivs_ingest_endpoint", returnStdout: true).trim()
          STREAM_KEY = sh(script: "terraform output -raw ivs_stream_key", returnStdout: true).trim()
          S3_BUCKET = sh(script: "terraform output -raw s3_website_bucket", returnStdout: true).trim()
          CLOUDFRONT = sh(script: "terraform output -raw cloudfront_domain", returnStdout: true).trim()
          // Export to env for next stage
          env.PLAYBACK_URL = PLAYBACK
          env.S3_BUCKET = S3_BUCKET
          // We prefer not to echo sensitive stream key, but we can print safe data.
          echo "Playback URL: ${PLAYBACK}"
          echo "Ingest endpoint: ${INGEST}"
        }
      }
    }

    stage('Generate + Upload Website') {
      steps {
        sh 'chmod +x scripts/generate_and_upload.sh'
        sh '''
          export PLAYBACK_URL="${PLAYBACK_URL}"
          export S3_BUCKET="${S3_BUCKET}"
          # get CloudFront distribution id (not domain) by looking up distribution list
          CLOUDFRONT_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?DomainName=='${CLOUDFRONT}'].Id | [0]" --output text || echo "")
          export CLOUDFRONT_DIST="${CLOUDFRONT_ID}"
          ./scripts/generate_and_upload.sh
        '''
      }
    }

    stage('Final Message') {
      steps {
        script {
          echo "Deployment finished."
          echo "Playback URL: ${env.PLAYBACK_URL}"
          echo "Viewer (CloudFront) domain: ${CLOUDFRONT}"
          echo "Give stream key (admin only) from Jenkins outputs (sensitive)"
        }
      }
    }
  }

  post {
    failure {
      echo "Pipeline failed. Check console logs."
    }
  }
}
