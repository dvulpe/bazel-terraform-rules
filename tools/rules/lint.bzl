load("@tf_modules//tools/rules:module.bzl", "TerraformModuleInfo")

def _impl(ctx):
    module = ctx.attr.module[TerraformModuleInfo]

    cmd = "{executor} -tflint {tflint} -terraform {terraform} -path {module_path} -tflint-config {tflint_config} ".format(
        executor = ctx.executable._executor.short_path,
        terraform = ctx.executable._terraform.short_path,
        tflint = ctx.executable._tflint.short_path,
        tflint_config = ctx.file._tflint_config.short_path,
        module_path = module.module_path,
    )
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )
    runtime_deps = [
        ctx.executable._terraform,
        ctx.executable._tflint,
        ctx.executable._executor,
        ctx.file._tflint_config,
    ]
    return [DefaultInfo(
        runfiles = ctx.runfiles(files = module.srcs + module.deps.to_list() + runtime_deps),
    )]

terraform_lint_test = rule(
    implementation = _impl,
    attrs = {
        "module": attr.label(providers = [TerraformModuleInfo]),
        "_executor": attr.label(
            default = Label("//tools/internal/linter:linter"),
            allow_files = True,
            executable = True,
            cfg = "target",
        ),
        "_terraform": attr.label(
            default = Label("@terraform_toolchain//:terraform_executable"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
        "_tflint": attr.label(
            default = Label("@tflint_toolchain//:tflint_executable"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
        "_tflint_config": attr.label(
            default = Label("//tools/rules:tflint-config.hcl"),
            allow_single_file = True,
        ),
    },
    test = True,
)
