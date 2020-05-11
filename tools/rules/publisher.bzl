load("@tf_modules//tools/rules:module.bzl", "TerraformModuleInfo")

def _impl(ctx):
    module = ctx.attr.module[TerraformModuleInfo]
    files = module.srcs + module.deps.to_list()

    manifest = ctx.actions.declare_file("manifest")
    ctx.actions.write(
        output = manifest,
        content = "\n".join([f.short_path for f in files]),
    )
    runtime_deps = [
        ctx.executable._packager,
        manifest,
    ]
    cmd = "{packager} -manifest {manifest}".format(
        packager = ctx.executable._packager.short_path,
        manifest = manifest.short_path,
    )
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )
    return [DefaultInfo(
        runfiles = ctx.runfiles(files = files + runtime_deps),
    )]

terraform_module_package = rule(
    implementation = _impl,
    attrs = {
        "module": attr.label(providers = [TerraformModuleInfo]),
        "_packager": attr.label(
            default = Label("//tools/internal/packager:packager"),
            allow_files = True,
            executable = True,
            cfg = "target",
        ),
    },
    executable = True,
)
