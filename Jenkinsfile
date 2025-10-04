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
                script {
                    def jarFile = bat(script: 'dir /b target\\spring-petclinic-*.jar', returnStdout: true).trim()
                    if (jarFile) {
                        echo "Deploying ${jarFile} to staging on port 7070..."
                        // Run in background so Jenkins can continue
                        bat "start /B java -jar target\\${jarFile} --spring.profiles.active=staging --server.port=7070"
                    } else {
                        echo "No JAR found in target/, skipping staging deploy"
                    }
                }
            }
        }
        
        stage('Release to Production') {
            steps {
                script {
                    def jarFile = bat(script: 'dir /b target\\spring-petclinic-*.jar', returnStdout: true).trim()
                    if (jarFile) {
                        echo "Releasing ${jarFile} to production on port 7070..."
                        // Run in background so Jenkins can continue
                        bat "start /B java -jar target\\${jarFile} --spring.profiles.active=prod --server.port=7070"
                    } else {
                        echo "No JAR found in target/, skipping production release"
                    }
                }
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
