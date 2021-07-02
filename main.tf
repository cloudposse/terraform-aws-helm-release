locals {
  enabled          = module.this.enabled
  iam_role_enabled = local.enabled && var.iam_role_enabled
}

module "eks_iam_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.1.0"

  enabled = local.iam_role_enabled

  iam_source_json_url   = var.iam_source_json_url
  iam_policy_statements = var.iam_policy_statements

  context = module.this.context
}

module "eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "0.8.0"

  enabled = local.iam_role_enabled

  aws_account_number          = var.aws_account_number
  aws_partition               = var.aws_partition
  aws_iam_policy_document     = local.iam_role_enabled ? module.eks_iam_policy.json : "{}"
  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url
  service_account_name        = var.service_account_name
  service_account_namespace   = var.service_account_namespace

  context = module.this.context
}

module "helm_release" {
  source  = "cloudposse/release/helm"
  version = "0.1.0"

  name          = module.this.name
  description   = var.description
  chart         = var.chart
  devel         = var.devel
  chart_version = var.chart_version

  repository           = var.repository
  repository_key_file  = var.repository_key_file
  repository_cert_file = var.repository_cert_file
  repository_ca_file   = var.repository_ca_file
  repository_username  = var.repository_username
  repository_password  = var.repository_password

  # Note: creating a namespace here will not allow creation of labels/annotations
  # For that, a `kubernetes_namespace` resource would have to be created.
  # See https://github.com/hashicorp/terraform-provider-helm/issues/584#issuecomment-689555268
  create_namespace = var.create_namespace
  namespace        = var.kubernetes_namespace

  values = var.values

  atomic                     = var.atomic
  cleanup_on_fail            = var.cleanup_on_fail
  dependency_update          = var.dependency_update
  disable_openapi_validation = var.disable_openapi_validation
  disable_webhooks           = var.disable_webhooks
  force_update               = var.force_update
  keyring                    = var.keyring
  lint                       = var.lint
  max_history                = var.max_history
  recreate_pods              = var.recreate_pods
  render_subchart_notes      = var.render_subchart_notes
  replace                    = var.replace
  reset_values               = var.reset_values
  reuse_values               = var.reuse_values
  skip_crds                  = var.skip_crds
  timeout                    = var.timeout
  verify                     = var.verify
  wait                       = var.wait
  wait_for_jobs              = var.wait_for_jobs
  set                        = var.set
  set_sensitive              = var.set_sensitive
  postrender_binary_path     = var.postrender_binary_path

  context = module.this.context
}
