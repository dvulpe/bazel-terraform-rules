TerraformModuleInfo = provider(
    doc = "Contains information about a Terraform module",
    fields = ["srcs", "deps", "module_path"],
)

def _impl(ctx):
    return [
        DefaultInfo(
            files = depset(ctx.files.srcs),
        ),
        TerraformModuleInfo(
            srcs = ctx.files.srcs,
            deps = depset(
                direct = [item for dep in ctx.attr.deps for item in dep[TerraformModuleInfo].srcs],
                transitive = [dep[TerraformModuleInfo].deps for dep in ctx.attr.deps],
            ),
            module_path = ctx.files.srcs[0].dirname,
        ),
    ]

terraform_module = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".tf"]),
        "deps": attr.label_list(providers = [TerraformModuleInfo]),
    },
)
