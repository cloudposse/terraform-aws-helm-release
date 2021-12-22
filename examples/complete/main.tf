locals {
  enabled = module.this.enabled
}

module "helm_release" {
  source = "../../"

  repository    = var.repository
  chart         = var.chart
  chart_version = var.chart_version

  create_namespace     = var.create_namespace
  kubernetes_namespace = var.kubernetes_namespace

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout
  wait            = var.wait

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    module.eks_cluster,
    module.eks_node_group,
  ]
}
