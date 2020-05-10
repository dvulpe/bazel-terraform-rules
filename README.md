# Terraform modules - a Bazel approach

This repository is the result of a short experiment meant to improve the engineering experience when working with Terraform.

### Why?
One approach for developing terraform and maximise code reuse is to enforce the use of modules early on. 
This tends to generally work well but all builds must be reproducible, and it requires version pinning.
Terraform modules mono-repositories work well in practice, but as the monorepo grows the terraform init tends to take
a while to run. 
There are a number of tools which can be used to create tests for terraform modules and modules should use them.
In my personal experience I have seen (and built) a number of tools to deal with usual monorepo building: 
detect which things need building, build them and publish the artefacts.

### Experiment
This is an experiment aimed at improving the experience of developing terraform modules. What I would like to prove is:
- low barrier for adding a new module
- for each added module it should be possible to:
    - run format checks (so that we can ensure the formatting is consistent)
    - run lint checks (to ensure the conventions are enforced)
    - publish it to a central repository
- modules can depend only on other modules
- a module should be published with its transitive dependencies 
- it should be possible to write blackbox tests and use the modules 
- should build and test incrementally
- modules should not depend on terraform test fixtures

### Solution
Over the years I have reinvented some tools. Sometimes it's easier to just fall back to previous experience, but for this experiment 
it felt right to use a familiar build tool some more and try to understand how to author rules.

On this journey this particular blog series https://jayconrod.com/posts/106/ on how to write bazel rules was of great help.

### Results
The results can be seen in this repo. All the rules/toolchains/providers are under `tools`. Let's see how the above criteria is met.

`low barrier for adding a new module` - this is as easy as adding a `BUILD` file to the module root containing:
```
load("@tf_modules//tools:def.bzl", "terraform_module")

terraform_module(
    name = "constants",
)
```
the module will then get three Bazel targets: format, lint and publish

`modules can depend only on other modules` - which is something accomplished by adding `deps` attribute:
```
load("@tf_modules//tools:def.bzl", "terraform_module")

terraform_module(
    name = "consumer",
    deps = [
        "//modules/constants",
    ],
)
``` 

`a module should be published with its transitive dependencies` - this is accomplished by using the deps above. The
publish target will have access to all the module sources (all .tf files) as well as the transitive dependencies sources.
 
`it should be possible to write blackbox tests and use the modules` - Terratest - https://github.com/gruntwork-io/terratest 
is configured and can build/teardown ephemeral infrastructure used for blackbox tests.
 
`should build and test incrementally` - this is mainly why I chose Bazel - as long as the rules are correct we will have
correct and fast builds.

`modules should not depend on terraform test fixtures` - test fixtures declared inside `examples` folder can only be
imported from the `test` submodules. This way none of the published terraform modules won't be able to pick up the test fixtures. 
