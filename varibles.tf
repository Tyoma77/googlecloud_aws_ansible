variable "aws_access_key" {
    description = "AWS access key"
    type        = string
}

variable "aws_secret_key" {
    description = "AWS secret key"
    type        = string
}

variable "project_name" {
    description = "Project name in google cloud"
    default     = "rebrain"
    type        = string
}

variable "google_region" {
    description = "Region of google cloud"
    type        = string
    default     = "us-central1"
}

variable "google_zone" {
    description = "Zone of google cloud"
    type        = string
    default     = "us-central1-c"
}

variable "google_cred_path" {
    description = "Path of the google cloud credentials file"
    type        = string
    default     = "key.json"
}

variable "lb_address_type" {
    description = "Type of load balancer address"
    type        = string
    default     = "EXTERNAL"
}

variable "lb_address_name" {
    description = "Name of load balancer address"
    type        = string
    default     = "load-balacer-address"
}

variable "email_tag" {
    description = "Email tag for resources"
    type        = string
    default     = "tyoma77_ya_ru"
}

variable "module_tag" {
    description = "Module tag for resources"
    type        = string
    default     = "devops"
}

variable "ssh_user" {
    description = "Default SSH user"
    type        = string
    default     = "ubuntu"
}

locals {
  google_cloud_ip_address = data.google_compute_instance.nat_addresses.*.network_interface.0.access_config.0.nat_ip 
}

variable "machines" {
    description = "names of creating machines"
    type        = list
    default     = ["staging-vm", "staging-vm-2"]
}

variable "machine_type" {
    description = "type of creating machine"
    type        = string
    default     = "e2-micro"
}

variable "aws_route53_record_prefix" {
    description = "AWS route53 record prefix"
    default     = "artem-vinogradov"
    type        = string
}

variable "aws_route53_record_type" {
    description = "AWS route53 record type"
    default     = "A"
    type        = string
}

variable "aws_route53_record_ttl" {
    description = "AWS route53 record ttl"
    default     = 300
    type        = number
}

variable "aws_route53_zone_name" {
    description = "AWS route53 zone name"
    default     = "devops.rebrain.srwx.net"
    type        = string
}

variable "aws_region" {
    description = "AWS region"
    default     = "eu-west-2"
    type        = string
}

variable "vpc_network_name" {
    description = "Name of the vpc network"
    default     = "vpc-network"
    type        = string
}

variable "image_family" {
    description = "Family of instance image"
    default     = "ubuntu-2104"
    type        = string
}

variable "image_project" {
    description = "Project of instance image"
    default     = "ubuntu-os-cloud"
    type        = string
}

variable "global_rule_name" {
    description = "Name of the global forwarding rule"
    default     = "nginx-global-rule"
    type        = string
}

variable "target_http_proxy_name" {
    description = "Name of the global forwarding rule"
    default     = "nginx-proxy"
    type        = string
}

variable "allow_health_check_rule_name" {
    description = "Name of the allow health check firewall rule"
    default     = "allow-health-check"
    type        = string
}

variable "allow_ssh_name" {
    description = "Name of the allow ssh firewall rule"
    default     = "allow-ssh"
    type        = string
}

variable "intance_group_name" {
    description = "Name of the intance group"
    default     = "nginx-instance-group"
    type        = string
}

variable "health_check_name" {
    description = "Name of the health check"
    default     = "nginx-health-check"
    type        = string
}

variable "backend_service_name" {
    description = "Name of the backend service"
    default     = "nginx-backend-service"
    type        = string
}

variable "url_map_name" {
    description = "Name of the url map"
    default     = "nginx-url-map"
    type        = string
}

variable "google_health_check_address" {
    description = "Addresses of google health check servieces"
    default     = ["130.211.0.0/22", "35.191.0.0/16"]
    type        = list
}