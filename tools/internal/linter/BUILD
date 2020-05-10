load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = ["linter.go"],
    importpath = "tfmodules/tools/internal/linter",
    visibility = ["//visibility:public"],
)

go_binary(
    name = "linter",
    embed = [":go_default_library"],
    visibility = ["//visibility:public"],
)
