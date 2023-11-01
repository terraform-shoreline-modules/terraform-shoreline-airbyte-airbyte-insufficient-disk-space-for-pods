resource "shoreline_notebook" "airbyte_pods_using_too_much_disk_space_and_failing_to_create_new_connections_in_kubernetes_cluster" {
  name       = "airbyte_pods_using_too_much_disk_space_and_failing_to_create_new_connections_in_kubernetes_cluster"
  data       = file("${path.module}/data/airbyte_pods_using_too_much_disk_space_and_failing_to_create_new_connections_in_kubernetes_cluster.json")
  depends_on = [shoreline_action.invoke_pods_disk_usage,shoreline_action.invoke_disk_space_cleanup,shoreline_action.invoke_delete_old_files]
}

resource "shoreline_file" "pods_disk_usage" {
  name             = "pods_disk_usage"
  input_file       = "${path.module}/data/pods_disk_usage.sh"
  md5              = filemd5("${path.module}/data/pods_disk_usage.sh")
  description      = "Print disk usage for each Airbyte pod"
  destination_path = "/tmp/pods_disk_usage.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "disk_space_cleanup" {
  name             = "disk_space_cleanup"
  input_file       = "${path.module}/data/disk_space_cleanup.sh"
  md5              = filemd5("${path.module}/data/disk_space_cleanup.sh")
  description      = "Identify and delete any unnecessary files or data that are consuming disk space in the Airbyte pods, for example /storage/airbyte-dev-logs"
  destination_path = "/tmp/disk_space_cleanup.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "delete_old_files" {
  name             = "delete_old_files"
  input_file       = "${path.module}/data/delete_old_files.sh"
  md5              = filemd5("${path.module}/data/delete_old_files.sh")
  description      = "Identify and delete any unnecessary old files that are consuming disk space in the Airbyte pod, for example /storage/airbyte-dev-logs"
  destination_path = "/tmp/delete_old_files.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pods_disk_usage" {
  name        = "invoke_pods_disk_usage"
  description = "Print disk usage for each Airbyte pod"
  command     = "`chmod +x /tmp/pods_disk_usage.sh && /tmp/pods_disk_usage.sh`"
  params      = ["NAMESPACE","POD_SELECTOR_LABELS"]
  file_deps   = ["pods_disk_usage"]
  enabled     = true
  depends_on  = [shoreline_file.pods_disk_usage]
}

resource "shoreline_action" "invoke_disk_space_cleanup" {
  name        = "invoke_disk_space_cleanup"
  description = "Identify and delete any unnecessary files or data that are consuming disk space in the Airbyte pods, for example /storage/airbyte-dev-logs"
  command     = "`chmod +x /tmp/disk_space_cleanup.sh && /tmp/disk_space_cleanup.sh`"
  params      = ["AIRBYTE_NAMESPACE","NAMESPACE","FILE_DIRECTORY"]
  file_deps   = ["disk_space_cleanup"]
  enabled     = true
  depends_on  = [shoreline_file.disk_space_cleanup]
}

resource "shoreline_action" "invoke_delete_old_files" {
  name        = "invoke_delete_old_files"
  description = "Identify and delete any unnecessary old files that are consuming disk space in the Airbyte pod, for example /storage/airbyte-dev-logs"
  command     = "`chmod +x /tmp/delete_old_files.sh && /tmp/delete_old_files.sh`"
  params      = ["FILE_DIRECTORY","AIRBYTE_POD_NAME"]
  file_deps   = ["delete_old_files"]
  enabled     = true
  depends_on  = [shoreline_file.delete_old_files]
}

