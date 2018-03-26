provider "google" {
  region = "${var.region}"
  project = "${var.project}"
}

// data "google_compute_zones" "available" {}

variable "cluster_name" {
  default = "terraform-example-cluster"
}

variable "kubernetes_version" {
  default = "1.6.7"
}

variable "username" {}
variable "password" {}

resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = 2

  node_version = "${var.kubernetes_version}"
min_master_version = "${var.kubernetes_version}"
enable_legacy_abac = false

//   additional_zones = [
//     "${data.google_compute_zones.available.names[1]}",
//   ]

  master_auth {
    username = "${var.username}"
    password = "${var.password}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    machine_type = "g1-small"
    disk_size_gb = 20
  }

addons_config {
  http_load_balancing {
    disabled = true
  }
  horizontal_pod_autoscaling {
    disabled = true
  }
  kubernetes_dashboard {
    disabled = true
  }
}

}

output "cluster_name" {
  value = "${google_container_cluster.primary.name}"
}

output "primary_zone" {
  value = "${google_container_cluster.primary.zone}"
}

output "additional_zones" {
  value = "${google_container_cluster.primary.additional_zones}"
}

output "endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
}

output "node_version" {
  value = "${google_container_cluster.primary.node_version}"
}
