terraform {
  /*
  backend "s3" {
    bucket         = "terraform-state-bucket-santhosh"
    region         = "ap-south-1"
    key            = "k8s-on-spot-instances/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
  */

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_iam_instance_profile" "instance-profile-for-master-node" {
  name_prefix = "${var.project-name}-"
  role        = aws_iam_role.master-node-role.name
}

resource "aws_instance" "master-node" {
  ami                    = var.master-node-ami
  instance_type          = var.master-node-instance-type
  user_data              = filebase64("${path.module}/${var.master-node-user-data-file}")
  vpc_security_group_ids = var.master-node-security-groups-ids
  iam_instance_profile   = aws_iam_instance_profile.instance-profile-for-master-node.name
  key_name               = var.master-node-key-pair-name
  tags                   = var.master-node-tags
}

resource "aws_iam_instance_profile" "instance-profile-for-worker-node" {
  name_prefix = "${var.project-name}-"
  role        = aws_iam_role.worker-node-role.name
}

resource "aws_launch_template" "worker-nodes-lt" {
  name_prefix = "${var.project-name}-"

  description = var.worker-nodes-lt-description

  vpc_security_group_ids = var.worker-nodes-vpc-sgs

  image_id = var.worker-nodes-ami

  iam_instance_profile {
    name = aws_iam_instance_profile.instance-profile-for-worker-node.name
  }

  key_name = var.worker-nodes-key-pair-name

  tags = var.worker-nodes-lt-tags

  tag_specifications {
    resource_type = "instance"
    tags          = var.worker-nodes-lt-propogate-tags
  }

  user_data = filebase64("${path.module}/${var.worker-nodes-user-data-file}")
}

data "aws_availability_zones" "list-of-AZs" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

resource "aws_autoscaling_group" "worker-nodes-asg" {
  name_prefix        = "${var.project-name}-"
  max_size           = var.worker-nodes-asg-max-size
  min_size           = var.worker-nodes-asg-min-size
  availability_zones = data.aws_availability_zones.list-of-AZs.names
  depends_on         = [aws_ssm_parameter.master-node-id-param]
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.worker-nodes-lt.id
        version            = "$Latest"
      }

      override {
        instance_requirements {
          memory_mib {
            min = var.worker-nodes-asg-min-memory-mb
            max = var.worker-nodes-asg-max-memory-mb
          }
          vcpu_count {
            min = var.worker-nodes-asg-min-vcpu
            max = var.worker-nodes-asg-max-vcpu
          }
        }
      }
    }
    instances_distribution {
      on_demand_base_capacity = var.worker-nodes-ondemand-base-capacity
    }
  }
}

resource "aws_ssm_parameter" "master-node-id-param" {
  name  = "/${var.project-name}/master-node-id"
  type  = "String"
  value = aws_instance.master-node.id
}

resource "aws_cloudwatch_event_rule" "spot-int-warn" {
  name_prefix = "${var.project-name}-"
  description = var.spot-inst-warn-cw-rule-description
  event_pattern = jsonencode({
    detail-type = ["EC2 Spot Instance Interruption Warning"],
    source      = ["aws.ec2"]
  })
}

resource "aws_cloudwatch_event_target" "spot-int-warn-target" {
  rule     = aws_cloudwatch_event_rule.spot-int-warn.name
  role_arn = aws_iam_role.eventbridge-role.arn
  arn      = "arn:aws:ssm:${var.region}::document/AWS-RunShellScript"
  run_command_targets {
    key    = "InstanceIds"
    values = [aws_instance.master-node.id]
  }
  input_transformer {
    input_paths    = var.spot-inst-warn-cw-rule-target-input-paths
    input_template = var.spot-inst-warn-cw-rule-target-input-template
  }
}