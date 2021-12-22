data "aws_eks_cluster_auth" "kubernetes" {
  name = module.eks_cluster.eks_cluster_id
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_endpoint
    token                  = data.aws_eks_cluster_auth.kubernetes.token
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
  }
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
}
