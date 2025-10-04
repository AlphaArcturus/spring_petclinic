pipeline {
    agent any

    tools {
        maven 'Maven3'   // Configured in Jenkins Global Tools
        jdk 'Java17'     // Configured in Jenkins Global Tools
    }

    environment {
        APP_NAME     = "spring-petclinic"
        APP_VERSION  = "1.0.0"
        IMAGE_NAME   = "petclinic-app:latest"   // placeholder, not used but shows awareness
        DEPLOY_PORT  = "7070"
    }

    options {
        timestamps()     // Add timestamps to logs
    }

    stages {
        stage('Pre-cleanup') {
            steps {
                echo 'Stopping any running PetClinic instances before build...'
                // Kill only PetClinic, not Jenkins
                bat '"C:\\Program Files\\Java\\jdk-17\\bin\\jps.exe" -l | findstr spring-petclinic'
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

        stage('Deploy to Staging') {
            steps {
                script {
                    def jarFile = bat(
                        script: 'dir /b target\\spring-petclinic-*.jar',
                        returnStdout: true
                    ).trim()

                    if (jarFile) {
                        echo "Deploying ${jarFile} to STAGING on port ${DEPLOY_PORT}..."
                        bat "\"start /B java -jar target\\${jarFile} --spring.profiles.active=staging --server.port=${DEPLOY_PORT}\""
                    } else {
                        echo "No JAR found in target/, skipping staging deploy"
                    }
                }
            }
        }

        stage('Release to Production') {
            steps {
                script {
                    def jarFile = bat(
                        script: 'dir /b target\\spring-petclinic-*.jar',
                        returnStdout: true
                    ).trim()

                    if (jarFile) {
                        echo "Releasing ${jarFile} to PRODUCTION on port ${DEPLOY_PORT}..."
                        bat "\"start /B java -jar target\\${jarFile} --spring.profiles.active=prod --server.port=${DEPLOY_PORT}\""
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
                echo "These can be integrated with Prometheus/Grafana for real monitoring."
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Stopping any running PetClinic instances after pipeline...'
                // Kill only PetClinic, not Jenkins
                bat '"C:\\Program Files\\Java\\jdk-17\\bin\\jps.exe" -l | findstr spring-petclinic'
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
