load("@bazel_gazelle//:def.bzl", "gazelle")
load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")
load("@tf_modules//tools:def.bzl", "terraform_module_package")

# gazelle:prefix tfmodules
gazelle(name = "gazelle")

buildifier(
    name = "buildifier",
)
