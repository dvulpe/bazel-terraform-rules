load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = ["packager.go"],
    importpath = "tfmodules/tools/internal/packager",
    visibility = ["//visibility:private"],
)

go_binary(
    name = "packager",
    embed = [":go_default_library"],
    visibility = ["//visibility:public"],
)
