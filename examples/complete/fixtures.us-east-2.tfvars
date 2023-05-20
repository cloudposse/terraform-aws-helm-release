region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "helm"

## eks related

availability_zones = ["us-east-2a", "us-east-2b"]

kubernetes_version = "1.26"
addons = [
  // https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#vpc-cni-latest-available-version
  {
    addon_name               = "vpc-cni"
    addon_version            = null
    resolve_conflicts        = "NONE"
    service_account_role_arn = null
  },
  // https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
  {
    addon_name               = "kube-proxy"
    addon_version            = null
    resolve_conflicts        = "NONE"
    service_account_role_arn = null
  },
  // https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
  {
    addon_name               = "coredns"
    addon_version            = null
    resolve_conflicts        = "NONE"
    service_account_role_arn = null
  },
]

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

repository = "https://aws.github.io/eks-charts/"

chart = "aws-node-termination-handler"

chart_version = "0.21.0"

create_namespace = true

kubernetes_namespace = "test"

atomic = true

cleanup_on_fail = true

timeout = 300

wait = true
