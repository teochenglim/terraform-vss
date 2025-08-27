# # Get Ubuntu 22.04 Deep Learning AMI
# https://docs.aws.amazon.com/dlami/latest/devguide/aws-deep-learning-base-gpu-ami-ubuntu-22-04.html
# $ aws ec2 describe-images --region ap-southeast-1 \
#       --owners amazon \
#       --filters 'Name=name,Values=Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04) ????????' 'Name=state,Values=available' \
#       --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' \
#       --output text
# ami-0fd15162cb8ee54b8
# aws ssm get-parameter --region ap-southeast-1 \
#     --name /aws/service/deeplearning/ami/x86_64/base-oss-nvidia-driver-gpu-ubuntu-22.04/latest/ami-id \
#     --query "Parameter.Value" \
#     --output text
# ami-0fd15162cb8ee54b8

data "aws_ssm_parameter" "gpu_ami" {
  name = "/aws/service/deeplearning/ami/x86_64/base-oss-nvidia-driver-gpu-ubuntu-22.04/latest/ami-id"
}

data "aws_ami" "deep_learning_gpu" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04) *"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# GPU Spot Instance with Grafana
resource "aws_instance" "gpu_spot" {
  ami           = data.aws_ami.deep_learning_gpu.id # data.aws_ssm_parameter.gpu_ami.value
  instance_type = var.instance_type # "g4dn.xlarge"
  # g4dn.xlarge: https://instances.vantage.sh/aws/ec2/g4dn.xlarge?region=ap-southeast-1
  # NVIDIA T4: https://aws.amazon.com/blogs/aws/now-available-ec2-instances-g4-with-nvidia-t4-tensor-core-gpus/
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = aws_key_pair.chenglimteo.key_name
  iam_instance_profile = aws_iam_instance_profile.gpu_instance_profile.name

  # Spot configuration
  # instance_market_options {
  #   market_type = "spot"
  #   spot_options {
  #     max_price = var.spot_max_price
  #   }
  # }

  # Root block device configuration - 200GB gp3
  root_block_device {
    volume_size = 500
    volume_type = "gp3"
    
  }

  vpc_security_group_ids = [aws_security_group.gpu_sg.id]
  user_data = templatefile("user_data.sh.tpl", {})

  tags = {
    Name = "GPU-VSS-Instance"
  }
}

resource "aws_iam_role" "gpu_instance_role" {
  name = "gpu-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "gpu_instance_s3_policy" {
  name = "gpu-instance-s3-access"
  role = aws_iam_role.gpu_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Effect = "Allow",
      Resource = [
        "arn:aws:s3:::chenglimteo",
        "arn:aws:s3:::chenglimteo/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "gpu_instance_profile" {
  name = "gpu-instance-profile"
  role = aws_iam_role.gpu_instance_role.name
}