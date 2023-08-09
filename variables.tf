## eks_iam

variable "iam_role_enabled" {
  type        = bool
  description = "Whether to create an IAM role. Setting this to `true` will also replace any occurrences of `{service_account_role_arn}` in `var.values_template_path` with the ARN of the IAM role created by this module."
  default     = false
}

## eks_iam_policy

variable "iam_policy_enabled" {
  type        = bool
  description = "Whether to create and attach an IAM policy to the created IAM role"
  default     = true
}

variable "iam_source_policy_documents" {
  type        = list(string)
  description = "List of JSON IAM policy documents that are merged together into role's policy. Statements defined in `source_policy_documents` or `source_json` must have unique sids."
  default     = null
}

variable "iam_source_json_url" {
  type        = string
  description = "IAM source json policy to download. The downloaded policy will be combined with `iam_source_policy_statements`."
  default     = null
}

variable "iam_policy_statements" {
  type        = any
  description = "DEPRECATED, use `iam_source_policy_documents` instead: IAM policy (as `map(string)`)for the service account."
  default     = {}
}

## eks_iam_role

variable "aws_account_number" {
  type        = string
  description = "AWS account number of EKS cluster owner."
  default     = null
}

variable "aws_partition" {
  type        = string
  description = "AWS partition: `aws`, `aws-cn`, or `aws-us-gov`. Applicable when `var.iam_role_enabled` is `true`."
  default     = "aws"
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for the EKS cluster (initial \"https://\" may be omitted)."

  validation {
    condition     = length(var.eks_cluster_oidc_issuer_url) > 0
    error_message = "The eks_cluster_oidc_issuer_url value must have a value."
  }
}

variable "service_account_role_arn_annotation_enabled" {
  type        = bool
  description = <<-EOT
  Whether or not to dynamically insert an `eks.amazonaws.com/role-arn` annotation into `$var.service_account_set_key_path.annotations`
  (by default, `serviceAccount.annotations`), with the value being the ARN of the IAM role created when `var.iam_role_enabled`.

  Assuming the Helm Chart follows the standard convention of rendering ServiceAccount annotations in `serviceAccount.annotations`
  (or a similar convention, which can be overriden by `var.service_account_set_key_path` as needed),
  this allows the ServiceAccount created by the Helm Chart to assume the IAM Role in question via the EKS OIDC IdP, without
  the consumer of this module having to set this annotation via `var.values` or `var.set`, which would involve manually
  rendering the IAM Role ARN beforehand.

  Ignored if `var.iam_role_enabled` is `false`.
  EOT
  default     = true
}

variable "service_account_set_key_path" {
  type        = string
  description = <<-EOT
  The key path used by Helm Chart values for ServiceAccount-related settings (e.g. `serviceAccount...` or `rbac.serviceAccount...`).

  Ignored if either `var.service_account_role_arn_annotation_enabled` or `var.iam_role_enabled` are set to `false`.
  EOT
  default     = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
}

variable "service_account_name" {
  type        = string
  description = <<-EOT
  Name of the Kubernetes ServiceAccount allowed to assume the IAM role created when `var.iam_role_enabled` is set to `true`.

  In combination with `var.service_account_namespace`, this variable is used to determine which ServiceAccounts are allowed
  to assume the IAM role in question.

  It is *not* recommended to leave this variable as `null` or `""`, as this would mean ServiceAccounts of any name in the
  namespace specified by `var.service_account_namespace` are allowed to assume the IAM role in question. If both variables
  are omitted, then a ServiceAccount of any name in any namespace will be able to assume the IAM role in question, which
  is the least secure scenario.

  The best practice is to set this variable to the name of the ServiceAccount created by the Helm Chart.
  EOT
  default     = null
}

variable "service_account_namespace" {
  type        = string
  description = <<-EOT
  Kubernetes Namespace of the Kubernetes ServiceAccount allowed to assume the IAM role created when `var.iam_role_enabled`
  is set to `true`.

  In combination with `var.service_account_name`, this variable is used to determine which ServiceAccounts are allowed
  to assume the IAM role in question.

  It is *not* recommended to leave this variable as `null` or `""`, as this would mean any ServiceAccounts matching the
  name specified by `var.service_account_name` in any namespace are allowed to assume the IAM role in question. If both
  variables are omitted, then a ServiceAccount of any name in any namespace will be able to assume the IAM role in question,
  which is the least secure scenario.

  The best practice is to set this variable to the namespace of the ServiceAccount created by the Helm Chart.
  EOT
  default     = null
}

### helm_release

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
}

variable "release_name" {
  type        = string
  description = "The name of the release to be installed. If omitted, use the name input, and if that's omitted, use the chart input."
  default     = ""
}

variable "description" {
  type        = string
  description = "Release description attribute (visible in the history)."
  default     = null
}

variable "devel" {
  type        = bool
  description = "Use chart development versions, too. Equivalent to version `>0.0.0-0`. If version is set, this is ignored."
  default     = null
}

variable "repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = null
}

variable "repository_ca_file" {
  type        = string
  description = "The Repositories CA file."
  default     = null
}

variable "repository_cert_file" {
  type        = string
  description = "The repositories cert file."
  default     = null
}

variable "repository_key_file" {
  type        = string
  description = "The repositories cert key file."
  default     = null
}

variable "repository_password" {
  type        = string
  description = "Password for HTTP basic authentication against the repository."
  default     = null
}

variable "repository_username" {
  type        = string
  description = "Username for HTTP basic authentication against the repository."
  default     = null
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}

variable "create_namespace" {
  type        = bool
  description = <<-EOT
    (Not recommended, use `create_namespace_with_kubernetes` instead)
    Create the namespace via Helm if it does not yet exist. Defaults to `false`.
    Does not support annotations or labels. May have problems when destroying.
    Ignored when `create_namespace_with_kubernetes` is set.
    EOT
  default     = null
}

variable "create_namespace_with_kubernetes" {
  type        = bool
  description = <<-EOT
    Create the namespace via Kubernetes if it does not yet exist. Defaults to `false`.
    Must set `true` if you want to use namespace annotations or labels.
    EOT
  default     = null
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into. Defaults to `default`."
  default     = null
}

variable "kubernetes_namespace_annotations" {
  type        = map(string)
  description = "Annotations to be added to the created namespace. Ignored unless `create_namespace_with_kubernetes` is `true`."
  default     = {}
}

variable "kubernetes_namespace_labels" {
  type        = map(string)
  description = "Labels to be added to the created namespace. Ignored unless `create_namespace_with_kubernetes` is `true`."
  default     = {}
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to `false`."
  default     = null
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to `false`."
  default     = null
}

variable "dependency_update" {
  type        = bool
  description = "Runs helm dependency update before installing the chart. Defaults to `false`."
  default     = null
}

variable "disable_openapi_validation" {
  type        = bool
  description = "If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema. Defaults to `false`."
  default     = null
}

variable "disable_webhooks" {
  type        = bool
  description = "Prevent hooks from running. Defaults to `false`."
  default     = null
}

variable "force_update" {
  type        = bool
  description = "Force resource update through delete/recreate if needed. Defaults to `false`."
  default     = null
}

variable "keyring" {
  type        = string
  description = "Location of public keys used for verification. Used only if `verify` is true. Defaults to `/.gnupg/pubring.gpg` in the location set by `home`."
  default     = null
}

variable "lint" {
  type        = bool
  description = "Run the helm chart linter during the plan. Defaults to `false`."
  default     = null
}

variable "max_history" {
  type        = number
  description = "Maximum number of release versions stored per release. Defaults to `0` (no limit)."
  default     = null
}

variable "recreate_pods" {
  type        = bool
  description = "Perform pods restart during upgrade/rollback. Defaults to `false`."
  default     = null
}

variable "render_subchart_notes" {
  type        = bool
  description = "If set, render subchart notes along with the parent. Defaults to `true`."
  default     = null
}

variable "replace" {
  type        = bool
  description = "Re-use the given name, even if that name is already used. This is unsafe in production. Defaults to `false`."
  default     = null
}

variable "reset_values" {
  type        = bool
  description = "When upgrading, reset the values to the ones built into the chart. Defaults to `false`."
  default     = null
}

variable "reuse_values" {
  type        = bool
  description = "When upgrading, reuse the last release's values and merge in any overrides. If `reset_values` is specified, this is ignored. Defaults to `false`."
  default     = null
}

variable "skip_crds" {
  type        = bool
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to `false`."
  default     = null
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds."
  default     = null
}

variable "values" {
  type        = any
  description = "List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options."
  default     = null
}

variable "verify" {
  type        = bool
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. For more information see the Helm Documentation. Defaults to `false`."
  default     = null
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`."
  default     = null
}

variable "wait_for_jobs" {
  type        = bool
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. It will wait for as long as `timeout`. Defaults to `false`."
  default     = null
}

variable "set" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  description = "Value block with custom values to be merged with the values yaml."
  default     = []
}

variable "set_sensitive" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff."
  default     = []
}

variable "postrender_binary_path" {
  type        = string
  description = "Relative or full path to command binary."
  default     = null
}

variable "permissions_boundary" {
  type        = string
  description = "ARN of the policy that is used to set the permissions boundary for the role."
  default     = null
}
