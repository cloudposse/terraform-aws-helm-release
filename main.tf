locals {
  enabled          = module.this.enabled
  iam_role_enabled = local.enabled && var.iam_role_enabled
}

module "eks_iam_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.3.0"

  enabled = local.iam_role_enabled

  iam_source_json       = var.iam_source_json
  iam_source_json_url   = var.iam_source_json_url
  iam_policy_statements = var.iam_policy_statements

  context = module.this.context
}

module "eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "0.10.3"

  enabled = local.iam_role_enabled

  aws_account_number          = var.aws_account_number
  aws_iam_policy_document     = local.iam_role_enabled ? module.eks_iam_policy.json : "{}"
  aws_partition               = var.aws_partition
  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url
  service_account_name        = var.service_account_name
  service_account_namespace   = var.service_account_namespace

  context = module.this.context
}

resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  # Allows var.name to be empty, which is allowed to be the case for this module since var.name is optional in eks-iam-role.
  # For more information, see: https://github.com/cloudposse/terraform-aws-eks-iam-role
  name = coalesce(module.this.name, var.chart)

  chart       = var.chart
  description = var.description
  devel       = var.devel
  version     = var.chart_version

  repository           = var.repository
  repository_ca_file   = var.repository_ca_file
  repository_cert_file = var.repository_cert_file
  repository_key_file  = var.repository_key_file
  repository_password  = var.repository_password
  repository_username  = var.repository_username

  # Note: creating a namespace here will not allow creation of labels/annotations
  # For that, a `kubernetes_namespace` resource would have to be created.
  # See https://github.com/hashicorp/terraform-provider-helm/issues/584#issuecomment-689555268
  create_namespace = var.create_namespace
  namespace        = var.kubernetes_namespace

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
  values                     = var.values
  verify                     = var.verify
  wait                       = var.wait
  wait_for_jobs              = var.wait_for_jobs

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = set.value["type"]
    }
  }

  dynamic "set_sensitive" {
    for_each = var.set_sensitive
    content {
      name  = set_sensitive.value["name"]
      value = set_sensitive.value["value"]
      type  = set_sensitive.value["type"]
    }
  }

  dynamic "set" {
    for_each = local.iam_role_enabled && var.service_account_role_arn_annotation_enabled ? [module.eks_iam_role.service_account_role_arn] : []
    content {
      name  = format("%s.annotations.eks\\.amazonaws\\.com/role-arn", var.service_account_set_key_path)
      value = set.value
      type  = "string"
    }
  }

  dynamic "postrender" {
    for_each = var.postrender_binary_path != null ? [1] : []

    content {
      binary_path = var.postrender_binary_path
    }
  }
}
