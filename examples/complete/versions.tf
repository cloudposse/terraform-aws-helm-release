terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.2"
    }
    kuberntes =  {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
  }
}
