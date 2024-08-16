variable "region" {
  type        = string
  description = "Region to deploy this solution"
}

variable "project-name" {
  type        = string
  description = "Name of this project. This is the prefix of name of most of the resources created."
}


/************************ Master Node Config  *****************************/

variable "master-node-instance-type" {
  type        = string
  description = "Master node instance class"
}

variable "master-node-security-groups-ids" {
  type        = list(string)
  description = "List of security group ids that has to be attached to master node"
}

variable "master-node-ami" {
  type        = string
  description = "AMI of the master node"
}

variable "master-node-key-pair-name" {
  type        = string
  description = "Key pair name that wanted to attached to master node"
}

variable "master-node-tags" {
  type        = map(string)
  description = "Tags of master node"
}

variable "master-node-user-data-file" {
  type        = string
  description = "User data file relative path"
}

variable "master-node-role-managed-policy-arns" {
  type        = list(string)
  description = "Managed ARNs list to be attached to master node profile role"
}

/****************************************************************************/

/************************ Worker Node Config  *****************************/

variable "worker-nodes-lt-description" {
  type        = string
  description = "Worker nodes' launch template description"
}

variable "worker-nodes-ami" {
  type        = string
  description = "Worker nodes' AMI"
}

variable "worker-nodes-lt-tags" {
  type        = map(string)
  description = "Worker nodes' launch template tags"
}

variable "worker-nodes-lt-propogate-tags" {
  type        = map(string)
  description = "Worker nodes' tags that's propogating from lt"
}

variable "worker-nodes-key-pair-name" {
  type        = string
  description = "Worker nodes' SSH ke pair name"
}

variable "worker-nodes-user-data-file" {
  type        = string
  description = "User data file relative path"
}

variable "worker-nodes-role-managed-policy-arns" {
  type        = list(string)
  description = "Managed ARNs list to be attached to worker node profile role"
}


variable "worker-nodes-asg-min-memory-mb" {
  type        = number
  description = "Worker nodes' launch template description"
}

variable "worker-nodes-asg-max-memory-mb" {
  type        = number
  description = "Worker nodes' maximum memory"
}

variable "worker-nodes-asg-min-vcpu" {
  type        = number
  description = "Worker nodes' minimum vCPU count"
}

variable "worker-nodes-asg-max-vcpu" {
  type        = number
  description = "Worker nodes' maximum vCPU count"
}

variable "worker-nodes-vpc-sgs" {
  type        = list(string)
  description = "Worker nodes' security groups"
}

variable "worker-nodes-asg-min-size" {
  type        = number
  description = "Minimum number of worker nodes in Autoscaling group"
}

variable "worker-nodes-asg-max-size" {
  type        = number
  description = "Maximum number of worker nodes in Autoscaling group"
}

variable "worker-nodes-ondemand-base-capacity" {
  type        = number
  description = "Number of on-demand instance to be there in the Autoscaling group"
}

/****************************************************************************/


/************************ CloudWatch rule Config  *****************************/


variable "spot-inst-warn-cw-rule-description" {
  type        = string
  description = "Name of the EventBridge rule"
}

variable "spot-inst-warn-cw-rule-target-input-paths" {
  type = object({
    spot_instance_id = string
  })
  description = "Input paths to extract values from event in CW rule target"
}


variable "spot-inst-warn-cw-rule-target-input-template" {
  type        = string
  description = "Template to prepare final input to the Document being ran"
}

/****************************************************************************/