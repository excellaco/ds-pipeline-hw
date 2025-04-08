pipeline {
    agent any
    
    environment {
        AWS_REGION          = 'us-east-1'
        TF_STATE_BUCKET     = 'ds-tf-state-bucket'
        STAGE               = 'dev'
        SONARQUBE_TOKEN     = credentials('sonarqube-token')
        OPA_POLICY_URL      = 'http://opa-policy-server/policies'
        DATA_LAKE_ADMIN_ARN = 'arn:aws:iam::123456789012:role/lf-admin-role'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                url: 'https://github.com/ds-account/data-science-hello-world.git'
            }
        }
        
        // Quality Gate - Extended for Data Science
        stage('Static Code Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh """
                    sonar-scanner \
                      -Dsonar.projectKey=data-science-hello-world \
                      -Dsonar.projectVersion=${env.BUILD_NUMBER} \
                      -Dsonar.sources=src \
                      -Dsonar.python.coverage.reportPaths=coverage.xml \
                      -Dsonar.exclusions=**/tests/**,**/node_modules/** \
                      -Dsonar.python.xunit.reportPath=test-reports/*.xml 
                    """
                }
            }
        }
        
        // Enhanced Security Scans
        stage('Security Scans') {
            parallel {
                stage('Infra Scan (Checkov)') {
                    steps {
                        sh 'docker run --rm -v $(pwd):/src bridgecrew/checkov -d /src/infra --framework terraform --soft-fail'
                    }
                }
                stage('Code Scan (Bandit)') {
                    steps {
                        sh 'bandit -r src -ll -iii --format json -o bandit-report.json'
                    }
                }
                stage('Dependency Scan') {
                    steps {
                        sh 'safety check --json --output-file safety-report.json'
                    }
                }
                stage('Lake Formation Policy Check') { 
                    steps {
                        sh """
                        opa eval \
                          --format pretty \
                          --data infra/policies/lakeformation.rego \
                          --input infra/variables.tf \
                          "data.lakeformation.valid"
                        """
                    }
                }
            }
        }
        
        // Terraform Workflow
        stage('Terraform Init') {
            steps {
                dir('infra') {
                    sh """
                    terraform init \
                      -backend-config="bucket=${TF_STATE_BUCKET}" \
                      -backend-config="key=data-science/${STAGE}/terraform.tfstate" \
                      -backend-config="region=${AWS_REGION}"
                    """
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    sh """
                    terraform plan \
                      -var="environment=${STAGE}" \
                      -var="data_lake_admins=[\"${DATA_LAKE_ADMIN_ARN}\"]" \
                      -out=tfplan
                    """
                }
            }
        }
        
        // Policy Compliance Check
        stage('Policy Compliance') {
            steps {
                script {
                    def tfPlanJson = sh(
                        script: 'cd infra && terraform show -json tfplan > ../tfplan.json',
                        returnStdout: true
                    )
                    
                    def opaResult = sh(
                        script: """
                        curl -X POST ${OPA_POLICY_URL}/terraform \
                          -H "Content-Type: application/json" \
                          -d @tfplan.json | jq -r '.result[]'
                        """,
                        returnStdout: true
                    ).trim()
                    
                    if (opaResult != "true") {
                        error "Policy violation detected: ${opaResult}"
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('infra') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        // Post-Deployment Validation - Enhanced
        stage('Validation') {
            parallel {
                stage('Validate Lambda') {
                    steps {
                        script {
                            def lambdaName = sh(
                                script: 'cd infra && terraform output -raw lambda_function_name',
                                returnStdout: true
                            ).trim()
                            
                            sh """
                            aws lambda invoke \
                              --function-name ${lambdaName} \
                              --payload '{"test":"data"}' \
                              --region ${AWS_REGION} \
                              lambda-response.json
                            """
                        }
                    }
                }
                
                stage('Test Glue Crawler') { 
                    steps {
                        script {
                            def crawlerName = sh(
                                script: 'cd infra && terraform output -raw glue_crawler_name',
                                returnStdout: true
                            ).trim()
                            
                            sh """
                            aws glue start-crawler --name ${crawlerName}
                            sleep 30  # Wait for crawler to start
                            aws glue get-crawler --name ${crawlerName} | jq -e '.Crawler.State == "RUNNING"'
                            """
                        }
                    }
                }
                
                stage('Verify Lake Formation') {
                    steps {
                        script {
                            def dbName = sh(
                                script: 'cd infra && terraform output -raw glue_database_name',
                                returnStdout: true
                            ).trim()
                            
                            sh """
                            aws lakeformation get-data-lake-settings | jq -e '.DataLakeSettings.DataLakeAdmins[] | select(. == "${DATA_LAKE_ADMIN_ARN}")'
                            aws glue get-database --name ${dbName} | jq -e '.Database.LocationUri'
                            """
                        }
                    }
                }
                
                stage('Test EC2 Connectivity') { 
                    steps {
                        script {
                            def instanceId = sh(
                                script: 'cd infra && terraform output -raw ec2_instance_id',
                                returnStdout: true
                            ).trim()
                            
                            sh """
                            aws ssm send-command \
                              --instance-ids ${instanceId} \
                              --document-name "AWS-RunShellScript" \
                              --parameters 'commands=["ls /opt"]' \
                              --region ${AWS_REGION}
                            """
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: '**/*report*.json,**/lambda-response.json', allowEmptyArchive: true
            junit '**/test-reports/*.xml'
            cleanWs()
        }
        success {
            slackSend(
                color: 'good',
                message: """SUCCESS: Data Science deployment to ${STAGE}
                - Lambda: ${env.BUILD_URL}/artifact/lambda-response.json
                - Glue Crawler Status: ${env.BUILD_URL}/console
                - SonarQube: ${env.SONAR_HOST_URL}/dashboard?id=data-science-hello-world"""
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: """FAILED: Data Science deployment
                - Build: ${env.BUILD_URL}
                - Check Terraform logs in Jenkins"""
            )
        }
    }
}