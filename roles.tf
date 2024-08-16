resource "aws_iam_role" "master-node-role" {
  name_prefix = "${var.project-name}-"
  path        = "/"
  #assume_role_policy = data.aws_iam_policy_document.assume_role.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },

    ]
  })
  managed_policy_arns = var.master-node-role-managed-policy-arns
}


resource "aws_iam_role" "worker-node-role" {
  name_prefix = "${var.project-name}-"
  path        = "/"
  #assume_role_policy = data.aws_iam_policy_document.assume_role.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },

    ]
  })

  inline_policy {
    name = "k8s-worker-node-inline-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:SendCommand",
            "ssm:ListCommandInvocations",
            "ssm:GetCommandInvocation"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        },

      ]
    })
  }

  managed_policy_arns = var.worker-nodes-role-managed-policy-arns
}



resource "aws_iam_role" "eventbridge-role" {
  name_prefix = "${var.project-name}-"
  path        = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },

    ]
  })

  inline_policy {
    name = "k8s-worker-node-inline-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:SendCommand",
            "ssm:ListCommandInvocations",
            "ssm:GetCommandInvocation"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        },

      ]
    })
  }
}