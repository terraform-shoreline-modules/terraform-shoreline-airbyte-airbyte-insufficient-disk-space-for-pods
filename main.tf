terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "airbyte_pods_using_too_much_disk_space_and_failing_to_create_new_connections_in_kubernetes_cluster" {
  source    = "./modules/airbyte_pods_using_too_much_disk_space_and_failing_to_create_new_connections_in_kubernetes_cluster"

  providers = {
    shoreline = shoreline
  }
}