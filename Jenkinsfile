pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    tools {
        terraform 'Terraform'
        ansible 'Ansible'
    }
    environment {
        AWS_DEFAULT_REGION = 'eu-west-1'
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init
                        terraform apply -auto-approve \
                        -var "aws_access_key=$AWS_ACCESS_KEY_ID" \
                        -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"
                    '''
                }
            }
        }

        stage('Extract EC2 Public IP') {
            steps {
                dir('terraform') {
                    script {
                        EC2_IP = sh(
                            script: "terraform output -raw ec2_public_ip",
                            returnStdout: true
                        ).trim()
                        echo "EC2 Public IP: ${EC2_IP}"
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'EC2-SSH-KEY', keyFileVariable: 'SSH_KEY')]) {
                    dir('ansible') {
                        script {
                            // Dynamic inventory creation
                            sh """
                                echo "[ec2]" > inventory.ini
                                echo "${EC2_IP} ansible_user=ec2-user ansible_ssh_private_key_file=${SSH_KEY}" >> inventory.ini
                            """
                        }
                        sh '''
                            ansible-playbook -i inventory.ini playbook.yml
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up Terraform resources..."
            dir('terraform') {
                sh 'terraform destroy -auto-approve || true'
            }
        }
    }
}
