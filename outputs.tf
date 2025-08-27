# Outputs
output "instance_public_ip" {
  value = aws_instance.gpu_spot.public_ip
}

output "ec2_nvidia_smi_check" {
  value = "ssh ubuntu@${aws_instance.gpu_spot.public_ip} nvidia-smi"
}