provider "aws" {
  region     = "eu-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a key pair using the public key from the repo
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = file("${path.module}/id_rsa.pub")
}

# Security group allowing SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 instance
resource "aws_instance" "jenkins_ec2" {
  ami                    = "ami-04f25a69b566c844b" # Amazon Linux 2 example (update if needed)
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Jenkins-Terraform-EC2"
  }
}

# Output EC2 public IP
output "ec2_public_ip" {
  value = aws_instance.jenkins_ec2.public_ip
}
