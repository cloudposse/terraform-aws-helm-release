region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "helm"

## eks related

availability_zones = ["us-east-2a"]

kubernetes_version = "1.21"

oidc_provider_enabled = true

enabled_cluster_log_types = ["audit"]

cluster_log_retention_period = 7

instance_types = ["t3.small"]

desired_size = 1

max_size = 3

min_size = 1

kubernetes_labels = {}

cluster_encryption_config_enabled = true

# no role to assume
kube_exec_auth_enabled = false
# use data auth
kube_data_auth_enabled = true

## helm related

repository = "https://charts.helm.sh/incubator"

chart = "raw"

chart_version = "0.2.5"

create_namespace = true

kubernetes_namespace = "aws-node-termination-handler"

atomic = true

cleanup_on_fail = true

timeout = 300

wait = true
