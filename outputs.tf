output "metadata" {
  description = "Block status of the deployed release."
  value       = try(module.helm_release.this[0].metadata, null)
}
