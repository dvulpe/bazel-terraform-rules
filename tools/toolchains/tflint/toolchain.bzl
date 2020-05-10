tflint_checksums = {
    "darwin_amd64": {
        "0.15.5": "5b4713e86dc094eb2a872cd83ae4ee19b4d093c1348fd96c3b02eb2a0288d752",
    },
    "linux_amd64": {
        "0.15.5": "81f8c8210af245c96be0da6351edfc60615334b9f35a13e5c8eb8fb901482a18",
    },
}

def get_dependencies(version):
    darwin_versions = tflint_checksums["darwin_amd64"]
    linux_versions = tflint_checksums["linux_amd64"]
    return {
        "darwin_amd64": {
            "os": "darwin",
            "arch": "amd64",
            "sha": darwin_versions[version],
            "exec_compatible_with": [
                "@platforms//os:osx",
                "@platforms//cpu:x86_64",
            ],
            "target_compatible_with": [
                "@platforms//os:osx",
                "@platforms//cpu:x86_64",
            ],
        },
        "linux_amd64": {
            "os": "linux",
            "arch": "amd64",
            "sha": linux_versions[version],
            "exec_compatible_with": [
                "@platforms//os:linux",
                "@platforms//cpu:x86_64",
            ],
            "target_compatible_with": [
                "@platforms//os:linux",
                "@platforms//cpu:x86_64",
            ],
        },
    }

url_template = "https://github.com/terraform-linters/tflint/releases/download/v{version}/tflint_{os}_{arch}.zip"

TflintInfo = provider(
    doc = "Information about how to invoke tflint.",
    fields = ["sha", "url"],
)

def _tflint_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        tflint = TflintInfo(
            sha = ctx.attr.sha,
            url = ctx.attr.url,
        ),
    )
    return [toolchain_info]

tflint_toolchain = rule(
    implementation = _tflint_toolchain_impl,
    attrs = {
        "sha": attr.string(),
        "url": attr.string(),
    },
)

def _format_url(version, os, arch):
    return url_template.format(version = version, os = os, arch = arch)

def declare_tflint_toolchain(version):
    dependencies = get_dependencies(version)
    for key, info in dependencies.items():
        url = _format_url(version, info["os"], info["arch"])
        name = "tflint_{}".format(key)
        toolchain_name = "{}_toolchain".format(name)

        tflint_toolchain(
            name = name,
            url = url,
            sha = info["sha"],
        )
        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = info["exec_compatible_with"],
            target_compatible_with = info["target_compatible_with"],
            toolchain = name,
            toolchain_type = "@tf_modules//tools:toolchain_type",
        )

def _detect_platform_arch(ctx):
    if ctx.os.name == "linux":
        platform, arch = "linux", "amd64"
    elif ctx.os.name == "mac os x":
        platform, arch = "darwin", "amd64"
    elif ctx.os.name.startswith("windows"):
        platform, arch = "windows", "amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return platform, arch

def _tflint_build_file(ctx, platform, version):
    ctx.file("ROOT")
    ctx.template(
        "BUILD.bazel",
        Label("@tf_modules//tools/toolchains/tflint:BUILD.toolchain"),
        executable = False,
        substitutions = {
            "{name}": "tflint_executable",
            "{version}": version,
        },
    )

def _remote_tflint(ctx, url, sha):
    ctx.download_and_extract(
        url = url,
        sha256 = sha,
        type = "zip",
        output = "tflint",
    )

def _tflint_register_toolchains_impl(ctx):
    platform, arch = _detect_platform_arch(ctx)
    version = ctx.attr.version
    _tflint_build_file(ctx, platform, version)

    host = "{}_{}".format(platform, arch)
    info = get_dependencies(version)[host]
    url = _format_url(version, info["os"], info["arch"])
    _remote_tflint(ctx, url, info["sha"])

_tflint_register_toolchains = repository_rule(
    _tflint_register_toolchains_impl,
    attrs = {
        "version": attr.string(),
    },
)

def register_tflint_toolchain(version = None):
    _tflint_register_toolchains(
        name = "tflint_toolchain",
        version = version,
    )
