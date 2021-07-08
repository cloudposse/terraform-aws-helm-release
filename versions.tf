terraform {
  required_version = ">= 0.13"

  required_providers {
    # Update these to reflect the actual requirements of your module
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.2"
    }
  }
}
