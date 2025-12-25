resource "aws_instance" "monitoring" {
  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.medium"

  subnet_id              = "subnet-0bb379fb12942e700"
  vpc_security_group_ids = [aws_security_group.monitoring.id]
  key_name               = "cicd-key"

  tags = {
    Name = "monitoring"
  }
}

resource "aws_security_group" "monitoring" {
  name   = "monitoring-sg"
  vpc_id = "vpc-0eb8eafb2ba6cd60c"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["93.86.194.2/32"]
  }

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = ["sg-031a9a42231d54756"]
  }
  
  ingress {
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["93.86.194.2/32"]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
