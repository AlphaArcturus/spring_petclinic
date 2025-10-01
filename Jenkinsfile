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

        stage('Build Artifact') {
            steps {
                bat 'mvn clean package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                echo 'Deploying PetClinic JAR to staging environment (simulated)'
                // Example: run the JAR directly instead of Docker
                bat 'java -jar target/spring-petclinic-*.jar --spring.profiles.active=staging || exit 0'
            }
        }
        
        stage('Release to Production') {
            steps {
                input message: "Promote to Production?", ok: "Release"
                echo 'Releasing PetClinic JAR to production environment (simulated)'
                bat 'java -jar target/spring-petclinic-*.jar --spring.profiles.active=prod || exit 0'
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
