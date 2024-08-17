/*************************************************

!!!!!!!!!!!!!!!  IMPORTANT  !!!!!!!!!!!!!!!!!!!

You might need to change following variables values as well, if you want to deploy this solution into your account.
1. master-node-ami (this may be common)
2. worker-nodes-ami (this may be common)
3. master-node-security-groups-ids
4. worker-nodes-vpc-sgs

************************************************/

region = "ap-south-1"

project-name = "k8s-on-spot"

/*************** Master Node  ****************/

master-node-instance-type       = "t3.medium"
master-node-security-groups-ids = ["sg-01ea920e733bef4ee"]
master-node-ami                 = "ami-0ad21ae1d0696ad58"
master-node-tags = {
  project   = "k8s-on-spot"
  node-type = "master"
  owner     = "santhosh"
  Name      = "k8s-on-spot-master-node"
}
master-node-role-managed-policy-arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
master-node-user-data-file           = "initialize-master-node.sh"

/***********************************************/


/*************** Worker Node  ****************/

worker-nodes-lt-description = "Launch template to define basic worker node requirement"
worker-nodes-ami            = "ami-0ad21ae1d0696ad58"
worker-nodes-lt-tags = {
  project = "k8s-on-spot"
  owner   = "santhosh"
}
worker-nodes-lt-propogate-tags = {
  project   = "k8s-on-spot"
  owner     = "santhosh"
  node-type = "worker"
  Name      = "k8s-on-spot-worker-node"
}
worker-nodes-user-data-file           = "initialize-worker-node.sh"
worker-nodes-role-managed-policy-arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
worker-nodes-asg-min-memory-mb        = 4000
worker-nodes-asg-max-memory-mb        = 6000
worker-nodes-asg-min-vcpu             = 2
worker-nodes-asg-max-vcpu             = 4
worker-nodes-vpc-sgs                  = ["sg-01ea920e733bef4ee"]
worker-nodes-asg-min-size             = 2
worker-nodes-asg-max-size             = 4
worker-nodes-ondemand-base-capacity   = 0

/*********************************************/

spot-inst-warn-cw-rule-description = "Rule to capture Spot Instance Interruption Warning event"
spot-inst-warn-cw-rule-target-input-paths = {
  spot_instance_id = "$.detail.instance-id"
}
spot-inst-warn-cw-rule-target-input-template = "{\"commands\": [\"sudo -H -u ubuntu bash -c 'kubectl drain <spot_instance_id> --ignore-daemonsets && kubectl delete node <spot_instance_id>'\"]}"