load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "fmtcheck_lib",
    srcs = ["fmtcheck.go"],
    importpath = "tfmodules/tools/internal/fmtcheck",
    visibility = ["//visibility:public"],
)

go_binary(
    name = "fmtcheck",
    embed = [":fmtcheck_lib"],
    visibility = ["//visibility:public"],
)
