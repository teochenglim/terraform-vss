# Security Group
resource "aws_security_group" "gpu_sg" {
  name        = "gpu-security-group"
  description = "Allow limited access to GPU instance"
  vpc_id      = aws_vpc.gpu_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "SSH access from allowed IP"
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "Access to FRONTEND_PORT from allowed IP"
  }

  ingress {
    from_port   = 8100
    to_port     = 8100
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "Access to BACKEND_PORT from allowed IP"
  }

  ingress {
    from_port   = 7474
    to_port     = 7474
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "Access to neo4j browser from allowed IP"
  }

  ingress {
    from_port   = 7687
    to_port     = 7687
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "Access to neo4j bolt from allowed IP"
  }

 ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "Access to LLM Instance from allowed IP"
  }

  ingress {
    from_port   = 9234
    to_port     = 9234
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "Access to embedding NIM from allowed IP"
  }


  ingress {
    from_port   = 9235
    to_port     = 9235
    protocol    = "tcp"
    cidr_blocks = [local.allowed_ip]
    description = "Access to reranker NIM from allowed IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "GPU-SG"
  }
}