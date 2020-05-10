load("@tf_modules//tools/toolchains/terraform:toolchain.bzl", "register_terraform_toolchain")
load("@tf_modules//tools/toolchains/tflint:toolchain.bzl", "register_tflint_toolchain")

def tools_register_toolchains(terraform_version = "0.12.24", tflint_version = "0.15.5"):
    register_terraform_toolchain(version = terraform_version)
    register_tflint_toolchain(version = tflint_version)
