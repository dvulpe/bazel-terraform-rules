module "constants" {
  source = "../../modules/constants"
}

output "test_constant" {
  value       = module.constants.test_constant
  description = "a test constant"
}
