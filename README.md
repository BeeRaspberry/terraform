# Infrastructure Repo

![Terraform Code Check](https://github.com/BeeRaspberry/infrastructure/workflows/Terraform%20Code%20Check/badge.svg)

This repo contains code to stand up a Kubernetes cluster, and supporting infrastructure. 

## Pre-requisites
*   [Terraform](https://www.terraform.io/) installed
*   Account with a Cloud Provider

## Infrastructure

*   VPC and subnets
*   Kubernetes cluster
*   Provider based Load Balancer
*   Bastion Server with Proxy

## Important Note

Terraform 'state' file is stored locally. This is fine for testing, but should be changed to a central store such as 'S3', or 'Google Storage'.

## Usage - General

Detailed instructions for cloud providers maybe found in their respective folders.

*   change directory to desired provider
*   copy `terraform.tfvars.sample` to `terraform.tfvars`
*   customize `terraform.tfvars` to suit your needs
*   run `terraform init`
*   run `terraform plan` or `terraform plan -out <file name>`
*   run `terraform apply` or `terraform apply <file name>`
