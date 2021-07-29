# googlecloud_aws_ansible
Project to deploy infrastracture on google cloud.
Deploying process:
  * Creatig saas load balancer
  * Creating instance group
  * Added route53 record
  * Generating ansible inventory file
  * Runnig ansible playbook to deploy nginx on cloud instances and add simple index.html file

Credentials needed:
  * aws account credentials
  * google cloud key.json file
Credentials should be written in terraform.tfvars file, the simple file is terraform.tfvars.simple
