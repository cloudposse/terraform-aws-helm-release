terraform {
  required_version = ">= 1.3.0"

  required_providers {
    # Update these to reflect the actual requirements of your module
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
  }
}
