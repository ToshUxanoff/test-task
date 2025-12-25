resource "aws_security_group" "runner_sg" {
  name   = "ci-cd-runner-sg"
  vpc_id = "vpc-0eb8eafb2ba6cd60c"

  ingress {
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

resource "aws_instance" "runner" {
  ami           = "ami-0ecb62995f68bb549" # Ubuntu 24
  instance_type = "t3.small"
  subnet_id     = "subnet-0bb379fb12942e700"
  key_name      = "cicd-key"
  tags = {
    Name = "ci-cd-runner"
  }
}
