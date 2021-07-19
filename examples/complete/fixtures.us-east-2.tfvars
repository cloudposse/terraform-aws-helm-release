region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "helm"

## eks related

availability_zones = ["us-east-2a", "us-east-2b"]

kubernetes_version = "1.19"

oidc_provider_enabled = true

enabled_cluster_log_types = ["audit"]

cluster_log_retention_period = 7

instance_types = ["t3.small"]

desired_size = 2

max_size = 3

min_size = 2

disk_size = 20

kubernetes_labels = {}

cluster_encryption_config_enabled = true

## helm related

repository = "https://charts.helm.sh/incubator"

chart = "raw"

chart_version = "0.2.5"

create_namespace = true

kubernetes_namespace = "echo"

atomic = true

cleanup_on_fail = true

timeout = 300

wait = true
