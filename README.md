1. backup and restore docker images

```
$ docker images
REPOSITORY                            TAG       IMAGE ID       CREATED        SIZE
nvcr.io/nvidia/blueprint/vss-engine   2.3.1     4966655efabf   3 weeks ago    46.6GB
neo4j                                 5.26.4    e294727afca3   4 months ago   539MB


docker save -o neo4j.tar neo4j:5.26.4
docker save -o vss-engine.tar nvcr.io/nvidia/blueprint/vss-engine:2.3.1

aws s3 cp neo4j.tar s3://chenglimteo/neo4j.tar
aws s3 cp vss-engine.tar s3://chenglimteo/vss-engine.tar


```

2. Load the docker image on the other host

```

aws s3 cp s3://chenglimteo/neo4j.tar neo4j.tar
aws s3 cp s3://chenglimteo/vss-engine.tar vss-engine.tar
docker load -i neo4j.tar
docker load -i vss-engine.tar

$ docker images
REPOSITORY                            TAG       IMAGE ID       CREATED        SIZE
nvcr.io/nvidia/blueprint/vss-engine   2.3.1     4966655efabf   3 weeks ago    46.6GB
neo4j                                 5.26.4    e294727afca3   4 months ago   539MB

```

3. OOM

```
via-server-1  | [07/22/2025-05:45:38] [TRT-LLM] [E] Failed to initialize executor on rank 0: CUDA out of memory. Tried to allocate 136.00 MiB. GPU 0 has a total capacity of 14.56 GiB of which 58.38 MiB is free. Process 244271 has 26.06 MiB memory in use. Process 238746 has 1.08 GiB memory in use. Process 244515 has 468.00 MiB memory in use. Including non-PyTorch memory, this process has 12.90 GiB memory in use. Of the allocated memory 12.72 GiB is allocated by PyTorch, and 69.61 MiB is reserved by PyTorch but unallocated. If reserved but unallocated memory is large try setting PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True to avoid fragmentation.  See documentation for Memory Management  (https://pytorch.org/docs/stable/notes/cuda.html#environment-variables)

```

4. beach account

```
### instance_type   = "g5.8xlarge"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
aws_vpc.gpu_vpc: Creating...
aws_key_pair.chenglimteo: Creating...
aws_iam_role.gpu_instance_role: Creating...
aws_key_pair.chenglimteo: Creation complete after 2s [id=chenglimteo]
aws_iam_role.gpu_instance_role: Creation complete after 2s [id=gpu-instance-role]
aws_iam_instance_profile.gpu_instance_profile: Creating...
aws_iam_role_policy.gpu_instance_s3_policy: Creating...
aws_iam_role_policy.gpu_instance_s3_policy: Creation complete after 1s [id=gpu-instance-role:gpu-instance-s3-access]
aws_iam_instance_profile.gpu_instance_profile: Creation complete after 8s [id=gpu-instance-profile]
aws_vpc.gpu_vpc: Still creating... [00m10s elapsed]
aws_vpc.gpu_vpc: Creation complete after 15s [id=vpc-02456ce397019d7d8]
aws_internet_gateway.igw: Creating...
aws_subnet.public_subnet: Creating...
aws_security_group.gpu_sg: Creating...
aws_internet_gateway.igw: Creation complete after 1s [id=igw-090d68a688e533adc]
aws_route_table.public_rt: Creating...
aws_route_table.public_rt: Creation complete after 3s [id=rtb-07273ade60909287a]
aws_security_group.gpu_sg: Creation complete after 5s [id=sg-0a401fa6b99eb87a5]
aws_subnet.public_subnet: Still creating... [00m10s elapsed]
aws_subnet.public_subnet: Creation complete after 12s [id=subnet-0e71de242202b16c7]
aws_route_table_association.public_rta: Creating...
aws_instance.gpu_spot: Creating...
aws_route_table_association.public_rta: Creation complete after 1s [id=rtbassoc-047efede3f4af3e02]
╷
│ Error: creating EC2 Instance: operation error EC2: RunInstances, https response error StatusCode: 403, RequestID: f290658d-25c1-4bea-9013-8367b9509493, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws:sts::160071257600:assumed-role/AWSReservedSSO_PowerUserPlusRole_db88d920cf78a35f/chenglim.teo@thoughtworks.com is not authorized to perform: ec2:RunInstances on resource: arn:aws:ec2:us-east-1:160071257600:instance/* with an explicit deny in a service control policy. Encoded authorization failure message: 2nZwGocTJ40E7w2L0VDDhG_WKCyFq0kX9zvNlM9ZboNds4EOHHnL3bjjlaka7KdDzgdjrZFMWWus5DayEM_ZePf7vfNYP-9EL2hqvKTiAJixxyw0nJU_0mS5unOcyaQyPVjiUP_VHGcQAvuL6YWgd4CZdMwoXgNp7IWtpz8KZBbFnlpZY9YNefQSZHOVws4Td1fsNFoNLOuVQvlrn8-Sj7IwzPP86ozoO2JuJbR1JZLZXc7UWldZSEy0fF6hrqAMp1tRGJXhzBPE7KgzLctE2WbTv5lg5fOTZrNPzCE5808F0EV5IDrz_MR0aNmzONTA7MguqN_KPj2maXVeZy1qz_NiSGAgQk_Fiz2znDUDTpYXK9PxhudauXMJfelTNq6z2yDpOMZLiDAhBWGE-ROJxruGWdqo-RtJgUnSetD9ahSwtnjqIL0IycFTpmkVpLH9f3wUJKNT_wzAgRSTVY1GQ9EpUITJbZyIXFP7_H9ODSjg32aogjaTuaEdDLQrTF-cgznXbE3CuDrf1xOK3zyFI-0sM7TFTzF6RYKj-EvFePIM0Plm_DeDSb7qWDmZzkUz_SgHKSJPUeE1caOMRBwNKz4BNkLAPkGtGlwbtgOQUjNGADf-6fUUkk4ZIA5GX8T5V5xVkZHPlAoGfFK41jjkCDFGXp0RpO9iizIh87lXA7vh7916HZ6HW-QLezIFS6TCRzvoxr1gsvnNgEFsLsYtW-4FQjSAEaMq0dAZAQ5IwqIEFx9RV7T_xO-YXjcWrzPzR24d7_PWZF2IwMuuHpyLB3iKuRQclzU_g9fdTKhFzSwER9lF5fE6LIaU0sAWwAESxyzraIlPP3sXC3B3qPEj-iOCG_x15y52_tAP4erWrg4lYhkZNqk-BtgmhDuPDL-pTtYSbvxuZIX26VNaeqLYHtQZ8fBZH278od4mZKGZSiwBo2W4H-RjF48dA16VUNRIpTgjWsEMEBBGTdWGhA3LlZh0ahaCmFNUfWit3TtAtcEJ5psxUC3EReFbpeBvLQYkYvUTxYKxVF9jxcnV3JpR-FapiUw5LS_unAshoQjFsOXA8cswKuiFOMiKZQtAujd0QhM
│
│   with aws_instance.gpu_spot,
│   on main.tf line 35, in resource "aws_instance" "gpu_spot":
│   35: resource "aws_instance" "gpu_spot" {
│
╵


### instance_type   = "p5.4xlarge"

chenglim.teo@MBP-clteo:~/code/terraform-vss (main)$ echo yes | terraform apply
data.http.my_ip: Reading...
data.http.my_ip: Read complete after 0s [id=https://ifconfig.me/ip]
data.aws_ami.deep_learning_gpu: Reading...
data.aws_ssm_parameter.gpu_ami: Reading...
aws_vpc.gpu_vpc: Refreshing state... [id=vpc-02456ce397019d7d8]
aws_key_pair.chenglimteo: Refreshing state... [id=chenglimteo]
aws_iam_role.gpu_instance_role: Refreshing state... [id=gpu-instance-role]
data.aws_ssm_parameter.gpu_ami: Read complete after 1s [id=/aws/service/deeplearning/ami/x86_64/base-oss-nvidia-driver-gpu-ubuntu-22.04/latest/ami-id]
aws_iam_role_policy.gpu_instance_s3_policy: Refreshing state... [id=gpu-instance-role:gpu-instance-s3-access]
aws_iam_instance_profile.gpu_instance_profile: Refreshing state... [id=gpu-instance-profile]
aws_internet_gateway.igw: Refreshing state... [id=igw-090d68a688e533adc]
aws_subnet.public_subnet: Refreshing state... [id=subnet-0e71de242202b16c7]
aws_security_group.gpu_sg: Refreshing state... [id=sg-0a401fa6b99eb87a5]
aws_route_table.public_rt: Refreshing state... [id=rtb-07273ade60909287a]
aws_route_table_association.public_rta: Refreshing state... [id=rtbassoc-047efede3f4af3e02]
data.aws_ami.deep_learning_gpu: Read complete after 4s [id=ami-0981cc40715055952]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.gpu_spot will be created
  + resource "aws_instance" "gpu_spot" {
      + ami                                  = "ami-0981cc40715055952"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = "gpu-instance-profile"
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "p5.4xlarge"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "chenglimteo"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "us-east-1"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = "subnet-0e71de242202b16c7"
      + tags                                 = {
          + "Name" = "GPU-VSS-Instance"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "Name"        = "GPU-VSS-Instance"
          + "Owner"       = "chenglimteo"
          + "Project"     = "chenglim.teo-gpu-vss"
        }
      + tenancy                              = (known after apply)
      + user_data                            = <<-EOT
            #!/bin/bash
            set -euxo pipefail
            sudo apt install git
        EOT
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = [
          + "sg-0a401fa6b99eb87a5",
        ]

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags_all              = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 500
          + volume_type           = "gp3"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_nvidia_smi_check = (known after apply)
  + instance_public_ip   = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
aws_instance.gpu_spot: Creating...
╷
│ Error: creating EC2 Instance: operation error EC2: RunInstances, https response error StatusCode: 403, RequestID: 682f40bc-00b2-4e83-b88d-be1c0e9dbb7e, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws:sts::160071257600:assumed-role/AWSReservedSSO_PowerUserPlusRole_db88d920cf78a35f/chenglim.teo@thoughtworks.com is not authorized to perform: ec2:RunInstances on resource: arn:aws:ec2:us-east-1:160071257600:instance/* with an explicit deny in a service control policy. Encoded authorization failure message: ePUtku9dTFST_EGpps31eSdg-R5TUQ2oSbg_cGvbXfF7R5Zl6M5KYezedFQ5enXxrYFsIeo5we_KjF9baCyp5rhOCc1V4O0INa1uDEZKnkPIC-OB7mmqgBb5okVZcjgM2mAaHuLB2NRSYa6wvzCCA6v2fNmRgwibXrKgn42-4UYXAqUV8hLBy8ZX79F1MVyOhzcUtyC0ThbaqMtbZ3O5esqGxFdEBzb45D17ps8Uu_fnJ1ERAIsP3kkMZepgDk3gP3AiwMr8GjoXyxGKBOcDmXpHzG1lKi28IDOCm9qETasBBBND1HepVhIpSdmjQemuCm2SiwajNz2N8OvvBOxjNmzBtQU5nfcaMe6rfjtXJWGOGMpsLjwI-ZjuUgy2CAWF2TRqR60nI_nKiGG7gRaOPcdTJOtic3FYK8KAUWgjRUqDXeVvmHMPdRc4mpVjJeyTay3jKr_g7te0GNk-CdMNTMPkT5YWTesSRP_PciPmwqyen19r7P9T88aCK46BNkLj5sXmr8ioJ_C0TuaDWjVah2U7-s3mHYSNuaYKXrJBPGDxG6rzN6fMgp_QxuO6t8lRanYwZwpQ5sYCL2DO1jTsI3qbw82QdqqIMan9Hl7ozjMalH-6YkI1oXM0Ww-1WRaGLiuaItPlknly7InVR-e5HHLNNtN1qxxluWRygR6goPDulAHqz15sRpDC8yuj8rBkNLeK4wSZtfwihc5R-sMumLmeE9ZPhyl1-dC7nku7WXauZGF5kKflGhFDaSjTSvgF36Yy3xd0adnt8q0GavWlNXGlHbXigz7EXOolPVZiDlOLduxRixN9_gkHGozsQMJW5A9f3X093Rm9BKkFNRcWcZBpXXV5GgMaGVjziNF36BjYU34FN01TlYB3MrKrAScYjUft8b-VHqRgmvRNJD92-j9m_6ymZ3vfiprp5fRZxfJoln2JRr_mrD5MpFK7PYcODvGAQ15ekWh1nOcPF33IbsMO02J6CSwMs_sh-QRMR308bohQFE75vCiXRSh4T--OQIO3uYsZYKf7RQD5qkuGkqf4AgfBFX05vGX6858XtbNAg-RkdK-aHHtV6Nf3R_-y4g
│
│   with aws_instance.gpu_spot,
│   on main.tf line 35, in resource "aws_instance" "gpu_spot":
│   35: resource "aws_instance" "gpu_spot" {
│
╵
```
