provider "google" {
  project      = var.project_name
  region       = var.google_region
  zone         = var.google_zone
  credentials  = var.google_cred_path
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key  
}


resource "google_compute_network" "vpc_network" {
  name = var.vpc_network_name
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow_health_check" {
  name    = var.allow_health_check_rule_name
  network = google_compute_network.vpc_network.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = var.google_health_check_address
  source_tags   = ["allow-health-check"]
}

resource "google_compute_firewall" "ssh-rule" {
  name    = var.allow_ssh_name
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance_group" "nginx_intance_group" {
  name        = var.intance_group_name
  description = "Instance group for load balancer"
  network     = google_compute_network.vpc_network.id
  instances   = google_compute_instance.staging_vm.*.self_link

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "ssh"
    port = "22"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "google_compute_image" "ubuntu_image" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_instance" "staging_vm" {
  count        = length(var.machines)
  name         = element(var.machines, count.index)
  machine_type = var.machine_type
  
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_image.self_link
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.instance_ansible_address[count.index].address
    }
  }
  
  metadata = {
   ssh-keys = "${var.ssh_user}:${file("${path.module}/terraform.pub")}"
 }
  
  allow_stopping_for_update = true
  
  labels = {
    email  = var.email_tag
    module = var.module_tag
  }

  depends_on = [
    google_compute_network.vpc_network
  ]
}

data "google_compute_instance" "nat_addresses" {
  count      = length(var.machines)
  name       = element(var.machines, count.index)
  depends_on = [google_compute_instance.staging_vm]
}

resource "google_compute_global_address" "loadbalancer_address" {
  name         = var.lb_address_name
  address_type = var.lb_address_type
}

resource "google_compute_address" "instance_ansible_address" {
  count        = length(var.machines)
  name         = "${element(var.machines, count.index)}-instance-address"
  address_type = var.lb_address_type
}

resource "google_compute_http_health_check" "nginx_health_check" {
  name               = var.health_check_name
  timeout_sec        = 1
  check_interval_sec = 1
}

resource "google_compute_backend_service" "nginx_backend_service" {
  name          = var.backend_service_name
  health_checks = [google_compute_http_health_check.nginx_health_check.id]
  backend {
    group = google_compute_instance_group.nginx_intance_group.id
  }
}

resource "google_compute_url_map" "urlmap" {
  name            = var.url_map_name
  description     = "a url map to route incomig reguests to backendservice"
  default_service = google_compute_backend_service.nginx_backend_service.id
}

resource "google_compute_target_http_proxy" "nginx_http_proxy" {
  name    = var.target_http_proxy_name
  url_map = google_compute_url_map.urlmap.id
}

resource "google_compute_global_forwarding_rule" "nginx_globalrule" {
  name       = var.global_rule_name
  target     = google_compute_target_http_proxy.nginx_http_proxy.id
  ip_address = google_compute_global_address.loadbalancer_address.id
  port_range = "80"
}

data "aws_route53_zone" "selected" {
  name = var.aws_route53_zone_name
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.aws_route53_record_prefix}.${var.aws_route53_zone_name}"
  type    = var.aws_route53_record_type
  ttl     = var.aws_route53_record_ttl
  records = [google_compute_global_address.loadbalancer_address.address,]
}

resource "local_file" "ansible_inventory" {
  content = "${templatefile("${path.module}/ansible_inventory.tpl", {
    name = var.machines
    ip_adr = local.google_cloud_ip_address
    }
  )}"
  filename = "${path.module}/ansible/inventory"
}

resource "null_resource" "ansible_run" {
    depends_on = [
      local_file.ansible_inventory,
  ]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ${path.module}/ansible/inventory ${path.module}/ansible/webserver.yml"
  }
}
