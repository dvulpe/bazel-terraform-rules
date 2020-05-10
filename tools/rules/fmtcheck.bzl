load("@tf_modules//tools/rules:module.bzl", "TerraformModuleInfo")

def _impl(ctx):
    module = ctx.attr.module[TerraformModuleInfo]

    cmd = "{executor} -terraform {terraform} -path {module_path}".format(
        executor = ctx.executable._executor.short_path,
        terraform = ctx.executable._terraform.short_path,
        module_path = module.module_path,
    )
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )
    runtime_deps = [
        ctx.executable._terraform,
        ctx.executable._executor,
    ]
    return [DefaultInfo(
        runfiles = ctx.runfiles(files = module.srcs + runtime_deps),
    )]

terraform_format_test = rule(
    implementation = _impl,
    attrs = {
        "module": attr.label(providers = [TerraformModuleInfo]),
        "_executor": attr.label(
            default = Label("//tools/internal/fmtcheck:fmtcheck"),
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
    },
    test = True,
    toolchains = ["@io_bazel_rules_go//go:toolchain"],
)
