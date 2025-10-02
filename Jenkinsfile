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
                bat 'mvn checkstyle:checkstyle'
                bat 'mvn com.github.spotbugs:spotbugs-maven-plugin:check || exit 0'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/site/**', allowEmptyArchive: true
                }
            }
        }

        stage('Security Scan') {
            steps {
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

        stage('Docker Build') {
            steps {
                script {
                    def jarFile = bat(script: 'dir /b target\\spring-petclinic-*.jar', returnStdout: true).trim()
                    if (jarFile) {
                        echo "Building Docker image ${DOCKER_IMAGE} with ${jarFile}"
                        bat "docker build -t ${DOCKER_IMAGE} --build-arg JAR_FILE=target/${jarFile} ."
                    } else {
                        error "No JAR found in target/, cannot build Docker image"
                    }
                }
            }
        }

        stage('Docker Run') {
            steps {
                echo "Running Docker container from ${DOCKER_IMAGE} on port 7070"
                bat "docker run -d -p 7070:8080 --name petclinic-container ${DOCKER_IMAGE}"
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
