pipeline {
    agent any

    tools {
        maven 'Maven3'   // Configured in Jenkins Global Tools
        jdk 'Java17'     // Configured in Jenkins Global Tools
    }

    environment {
        APP_NAME     = "spring-petclinic"
        APP_VERSION  = "1.0.0"
        IMAGE_NAME   = "petclinic-app"   // base image name
        DEPLOY_PORT  = "7070"
    }

    options {
        timestamps()     // Add timestamps to logs
    }

    stages {
        stage('Pre-cleanup') {
            steps {
                echo 'Stopping any running PetClinic containers before build...'
                bat 'docker rm -f petclinic-staging || exit 0'
                bat 'docker rm -f petclinic-prod || exit 0'
            }
        }

        stage('Build & Package') {
            steps {
                bat 'mvn clean package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
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

        stage('Deploy to Staging (Docker)') {
            steps {
                script {
                    def jarFile = bat(
                        script: 'dir /b target\\spring-petclinic-*.jar',
                        returnStdout: true
                    ).trim()

                    if (jarFile) {
                        echo "Building Docker image for ${jarFile}..."
                        bat "docker build -t ${IMAGE_NAME}-staging ."

                        echo "Running container on port ${DEPLOY_PORT}..."
                        bat "docker run -d -p ${DEPLOY_PORT}:8080 --name petclinic-staging ${IMAGE_NAME}-staging"
                    } else {
                        echo "No JAR found in target/, skipping staging deploy"
                    }
                }
            }
        }

        stage('Release to Production (Docker)') {
            steps {
                script {
                    def jarFile = bat(
                        script: 'dir /b target\\spring-petclinic-*.jar',
                        returnStdout: true
                    ).trim()

                    if (jarFile) {
                        echo "Building Docker image for ${jarFile}..."
                        bat "docker build -t ${IMAGE_NAME}-prod ."

                        echo "Running container on port 8081..."
                        bat "docker run -d -p 8081:8080 --name petclinic-prod ${IMAGE_NAME}-prod"
                    } else {
                        echo "No JAR found in target/, skipping production release"
                    }
                }
            }
        }

        stage('Monitoring & Metrics') {
            steps {
                echo "Spring Boot Actuator endpoints available at:"
                echo "  http://localhost:${DEPLOY_PORT}/actuator/health"
                echo "  http://localhost:${DEPLOY_PORT}/actuator/metrics"
                echo "Production would be at http://localhost:8081/actuator/health"
            }
        }
    }   // closes stages

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs and reports.'
        }
    }   // closes post
}       // closes pipeline
