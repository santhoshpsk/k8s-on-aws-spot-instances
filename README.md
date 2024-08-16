# Kubernetes on AWS EC2 Spot Instances

![Handling Spot Instance Termination](<assets/Spot-Int-Sig-handling.gif>)

This project demonstrates how to set up and run a Kubernetes cluster on AWS EC2 Spot Instances, taking advantage of the cost savings offered by Spot Instances while maintaining a robust and resilient infrastructure.

# Table of contents
* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Architecture](#architecture)
* [Challenges of using Spot Instances](#challenges-of-using-spot-instances)

## Introduction
This project is aimed at demonstrating a cost-effective way to run Kubernetes clusters using AWS EC2 Spot Instances. Spot Instances allow you to bid on unused EC2 capacity, offering significant savings compared to On-Demand Instances. However, they come with the risk of being terminated when AWS needs the capacity back, which adds an interesting challenge to maintaining a resilient Kubernetes cluster.

![Overall Structure](<assets/overall-structure.gif>)

## Prerequisites
Before starting, ensure you have the following:

* An AWS account
* Terraform installed on your local machine
* kubectl installed on your local machine

## Architecture
The architecture of this project includes:

* EC2 Spot Instances: Running Kubernetes nodes.
* Auto Scaling Group (ASG): Ensuring the desired number of Spot Instances are always running.
* Kubernetes Master Nodes: Running on On-Demand Instance.
* Load Balancer: For distributing traffic across your Kubernetes nodes.

## Challenges of using Spot Instances
Using Spot Instances for a Kubernetes cluster can significantly reduce costs, but it introduces a challenge that need to be carefully managed:

### Instance Termination
Spot Instances can be terminated with little notice when AWS needs the capacity back, which can disrupt your applications.

#### Understanding Spot Instance Termination
When AWS reclaims the capacity of a Spot Instance, it sends a termination notice to the instance. This notice is typically sent two minutes before the instance is terminated. It's crucial to use this time effectively to ensure a graceful shutdown and to minimize the impact on your Kubernetes cluster.

#### Graceful Node Draining
When a termination notice is received, it's essential to drain the node to ensure that running pods are safely evicted and rescheduled on other nodes. Draining involves marking the node as unschedulable and evicting all pods.

Steps for Draining a Node:

* **Step 1:** Detect termination notice via AWS EventBridge rule.
* **Step 2:** Trigger a Kubernetes kubectl drain command for the node using AWS Systems Manager Document run.
* **Step 3:** Kubernetes evicts pods from the node.
* **Step 4:** Once all pods are evicted, the node can be safely terminated.

![Handling Spot Instance Termination](<assets/Spot-Int-Sig-handling.gif>)