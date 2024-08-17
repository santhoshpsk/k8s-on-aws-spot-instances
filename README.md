# Kubernetes on AWS EC2 Spot Instances

![Handling Spot Instance Termination](<assets/Spot-Int-Sig-handling.gif>)

This project demonstrates how to set up and run a Kubernetes cluster on AWS EC2 Spot Instances, taking advantage of the cost savings offered by Spot Instances while maintaining a robust and resilient infrastructure.

# Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Challenges of Using Spot Instances](#challenges-of-using-spot-instances)
- [Installation](#installation)

## Introduction
Running Kubernetes clusters on AWS EC2 Spot Instances offers significant cost savings by allowing you to bid on unused EC2 capacity. However, Spot Instances can be terminated with little notice when AWS reclaims capacity, posing a challenge to maintaining a stable and resilient Kubernetes environment.

![Overall Structure](<assets/overall-structure.gif>)

## Prerequisites
Before you begin, ensure the following are in place:

- An AWS account
- Terraform installed locally
- kubectl installed locally

## Architecture
The project architecture includes:

- **EC2 Spot Instances:** Running Kubernetes nodes.
- **Auto Scaling Group (ASG):** Ensuring the desired number of Spot Instances are maintained.
- **Kubernetes Master Nodes:** Deployed on On-Demand Instances for stability.

## Challenges of Using Spot Instances
While Spot Instances reduce costs, they come with the risk of termination when AWS reclaims capacity, which can disrupt your cluster.

### Handling Instance Termination
AWS provides a two-minute termination notice when reclaiming a Spot Instance. This short window requires efficient handling to minimize disruption to your Kubernetes cluster.

#### Graceful Node Draining Process
When a termination notice is received:

1. **Detect Termination Notice:** Capture the event using an AWS EventBridge rule.
2. **Trigger Node Draining:** Use AWS Systems Manager to run a `kubectl drain` command, making the node unschedulable and evicting all pods.
3. **Evict and Reschedule Pods:** Kubernetes evicts the pods, and they are rescheduled on other available nodes.
4. **Safe Termination:** Once all pods are evicted, the node is safely terminated.

![Handling Spot Instance Termination](<assets/Spot-Int-Sig-handling.gif>)

## Installation
### Deploying with Terraform
This project is fully deployable using Terraform. You can modify configurations to suit your environment:

- Tested in the ap-south-1 region.
- Review and adjust settings in `terraform.tfvars` if deploying in a different region or account.
- No key-pair is attached to EC2 instances to reduce dependency, but all instances are configured to join Systems Manager, allowing connection through Systems Manager Sessions.
