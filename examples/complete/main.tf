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

provider "kubernetes" {
  host                   = module.eks_cluster.eks_cluster_endpoint
  token                  = data.aws_eks_cluster_auth.kubernetes.token
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
}


module "helm_release" {
  source = "../../"

  # source  = "cloudposse/helm-release/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"

  repository    = var.repository
  chart         = var.chart
  chart_version = var.chart_version

  create_namespace_with_kubernetes = var.create_namespace
  kubernetes_namespace             = var.kubernetes_namespace
  service_account_namespace        = var.kubernetes_namespace
  service_account_name             = "aws-node-termination-handler"
  iam_role_enabled                 = true
  iam_source_policy_documents      = [one(data.aws_iam_policy_document.node_termination_handler[*].json)]

  eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout
  wait            = var.wait

  values = [
    file("${path.module}/values.yaml")
  ]

  context = module.this.context

  depends_on = [
    module.eks_cluster,
    module.eks_node_group,
  ]
}

data "aws_iam_policy_document" "node_termination_handler" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
    ]
  }
}
