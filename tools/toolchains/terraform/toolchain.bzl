terraform_checksums = {
    "darwin_amd64": {
        "0.12.23": "ca1a0bc58b4e482d0bdcaee95d002f4901094935fd4b184f57563a5c34fd18d9",
        "0.12.24": "72482000a5e25c33e88e95d70208304acfd09bf855a7ede110da032089d13b4f",
    },
    "linux_amd64": {
        "0.12.23": "78fd53c0fffd657ee0ab5decac604b0dea2e6c0d4199a9f27db53f081d831a45",
        "0.12.24": "602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11",
    },
}

def get_dependencies(version):
    darwin_versions = terraform_checksums["darwin_amd64"]
    linux_versions = terraform_checksums["linux_amd64"]
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

TerraformInfo = provider(
    doc = "Information about how to invoke Terraform.",
    fields = ["sha", "url"],
)

def _terraform_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        terraform = TerraformInfo(
            sha = ctx.attr.sha,
            url = ctx.attr.url,
        ),
    )
    return [toolchain_info]

terraform_toolchain = rule(
    implementation = _terraform_toolchain_impl,
    attrs = {
        "sha": attr.string(),
        "url": attr.string(),
    },
)

def declare_terraform_toolchain(version):
    dependencies = get_dependencies(version)
    for key, info in dependencies.items():
        url = _format_url(version, info["os"], info["arch"])
        name = "terraform_{}".format(key)
        toolchain_name = "{}_toolchain".format(name)

        terraform_toolchain(
            name = name,
            url = url,
            sha = info["sha"],
        )
        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = info["exec_compatible_with"],
            target_compatible_with = info["target_compatible_with"],
            toolchain = name,
            toolchain_type = "@tf_modules//tools/toolchains/terraform:toolchain_type",
        )

def _detect_platform_arch(ctx):
    if ctx.os.name == "linux":
        platform, arch = "linux", "amd64"
    elif ctx.os.name == "mac os x":
        platform, arch = "darwin", "amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return platform, arch

def _terraform_build_file(ctx, platform, version):
    ctx.template(
        "BUILD",
        Label("@tf_modules//tools/toolchains/terraform:BUILD.toolchain"),
        executable = False,
        substitutions = {
            "{name}": "terraform_executable",
            "{version}": version,
        },
    )

def _format_url(version, os, arch):
    url_template = "https://releases.hashicorp.com/terraform/{version}/terraform_{version}_{os}_{arch}.zip"
    return url_template.format(version = version, os = os, arch = arch)

def _impl(ctx):
    platform, arch = _detect_platform_arch(ctx)
    version = ctx.attr.version
    _terraform_build_file(ctx, platform, version)

    host = "{}_{}".format(platform, arch)
    info = get_dependencies(version)[host]

    ctx.download_and_extract(
        url = _format_url(version, info["os"], info["arch"]),
        sha256 = info["sha"],
        type = "zip",
        output = "terraform",
    )

_terraform_register_toolchains = repository_rule(
    implementation = _impl,
    attrs = {
        "version": attr.string(),
    },
)

def register_terraform_toolchain(version = None):
    _terraform_register_toolchains(
        name = "terraform_toolchain",
        version = version,
    )
