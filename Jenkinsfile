pipeline {
    agent any

    tools {
        maven 'Maven3'   // Configured in Jenkins Global Tools
        jdk 'Java17'     // Configured in Jenkins Global Tools
    }

    environment {
        DOCKER_IMAGE = "petclinic-app:latest"
    }

    stages {

        stage('Build') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                bat 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Code Quality') {
            steps {
                echo '=== Code Quality Stage ==='
        
                // Run Checkstyle in "report only" mode (does not fail build)
                bat 'mvn checkstyle:checkstyle'
        
                // Run SpotBugs static analysis (ignore failures, just report)
                bat 'mvn com.github.spotbugs:spotbugs-maven-plugin:check || exit 0'
            }
            post {
                always {
                    // Archive generated reports so you can show them in your submission
                    archiveArtifacts artifacts: 'target/site/**', allowEmptyArchive: true
                }
            }
        }

        stage('Security Scan') {
            steps {
                // OWASP Dependency-Check plugin or CLI
                bat 'mvn org.owasp:dependency-check-maven:check'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/dependency-check-report.html', allowEmptyArchive: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %DOCKER_IMAGE% ."
            }
        }

        stage('Deploy to Staging') {
            steps {
                // Stop old container if running
                bat '''
                docker stop petclinic-staging || exit 0
                docker rm petclinic-staging || exit 0
                docker run -d -p 8080:8080 --name petclinic-staging %DOCKER_IMAGE%
                '''
            }
        }

        stage('Release to Production') {
            steps {
                input message: "Promote to Production?", ok: "Release"
                bat '''
                docker stop petclinic-prod || exit 0
                docker rm petclinic-prod || exit 0
                docker run -d -p 9090:8080 --name petclinic-prod %DOCKER_IMAGE%
                '''
            }
        }

        stage('Monitoring & Metrics') {
            steps {
                echo 'Spring Boot Actuator endpoints available at /actuator/health and /actuator/metrics'
                echo 'Configure Prometheus to scrape metrics and Grafana to visualize dashboards'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs and reports.'
        }
    }
}
