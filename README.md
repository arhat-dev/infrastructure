# Template Kubernetes Cluster

[![CI](https://github.com/arhat-dev/template-kubernetes-cluster/workflows/CI/badge.svg)](https://github.com/arhat-dev/template-kubernetes-cluster/actions?query=workflow%3ACI)

Create service infrastructure on top of Kubernetes for all kinds of environment

__NOTE:__ Chart dependencies in this repository are updated weekly according to the the [renovate dashboard](https://github.com/arhat-dev/template-kubernetes-cluster/issues/20), please do not send pull request for chart upgrade.

## Prerequisites

- `helm-stack` and `helm` binary installed to local PATH (or docker installed to run them in container with `make`)
  - To install `helm-stack`, run `GOOS=$(go env GOHOSTOS) GOARCH=$(go env GOHOSTARCH) go get -u arhat.dev/helm-stack/cmd/helm-stack`
  - To install `helm`, please refer to the [official guide](https://helm.sh/docs/intro/install/)
- GNU `make` (optoinal if you know how to invoke `helm-stack` correctly)

## Workflow

### Before you start

Create a private repo using this template to avoid any credential leak.

### Initial Provisioning

1. Add or update helm repo and helm chart references in [`.helm-stack/charts`](./.helm-stack/charts) and [`.helm-stack/repos.yaml`](./.helm-stack/repos.yaml)

   ```yaml
   repos:
     # name of the chart repo
   - name: example

     # url of chart repo
     url: https://example.com/helm-charts

     # (optional) authentication
     auth:
       # http basic is the only auth method supported by helm
       httpBasic:
         username: foouser
         password: foopassword

     # (optional) tls configuration
     tls:
       # certificate ca file path
       caCert: /path/to/ca.crt
       cert: /path/to/cert.pem
       key: /path/to/key.pem
       # establish tls connection even not verified
       insecureSkipVerify: false

   charts:
     # if it is a chart from a standard chart repo, the chart definition only requires `name`
     # and the `name` format is `<CHART_REPO>/<CHART_NAME>@<CHART_VERSION>`
   - name: bitnami/metallb@0.1.24

     # if it is a chart from a git repository, the chart definition requires `name` and `git`
     # repo source config, and the name format is `<CHART_NAME>@<GIT_TAG>` where GIT_TAG will
     # be treated as CHART_VERSION
     # (of course you can include `/` in the name)
   - name: ingress-nginx@ingress-nginx-3.3.0
     git:
       # repo url
       url: https://github.com/kubernetes/ingress-nginx
       # relative path in the repo
       path: charts/ingress-nginx

     # if it is a chart created locally and not published anywhere, the chart definition requires
     # `name` and `local`, the name format is the same with the ones from git repo
     # NOTE: you should include local charts in .gitignore
   - name: foo@latest
     # local has no specification for now
     # local chart won't copy from anywhere, you should create and maintain it in this repo
     local: {}
   ```

1. You may need to add these new repos to the `"packageRules"` section in [`.renovaterc.json`](./.renovaterc.json) for automatic chart upgrade

   ```js
   {
     // ...
     "packageRules": [
       // ...
       {
         "managers": ["regex"],
         "datasources": ["helm"],
         "semanticCommitScope": "charts",
         "labels": ["charts"],
         "packagePatterns": ["^example/"],                   // TODO: change the prefix
         "groupName": "example",                             // TODO: change the group name
         "registryUrls": ["https://example.com/helm-chart"]  // TODO: change the url (only one url allowed)
       },
       // ...
     ]
   }
   ```

1. Define your clusters (environments) in [`.helm-stack/clusters`](./.helm-stack/clusters) (You can start with a reference cluster config: [`docs/sample-cluster.yaml`](./docs/sample-cluster.yaml))

   ```yaml
   environments:
     # name of the cluster
   - name: <CLUSTER_NAME>

     # (optional) kubeconfig context name for this cluster, used for kubectl apply/delete flag
     # `--context <context name>`, if not set or set to empty, will use default `current-context`
     # in kubeconfig (default: "")
     kubeContext: <CLUSTER_NAME>-admin@<CLUSTER_NAME>

     # charts to deploy
     deployments:
       # deployment name sets deployment `<namespace>` for helm template flag `--namespace <namespace>`
       # and `<name>` for helm template flag `--set fullnameOverride=<name>`
     - name: <namespace>/<name>
       # chart name we have defined in previous config files
       chart: <CHART_NAME>
       # the values file used as default values (default: values.yaml)
       baseValues: values-production.yaml
       # set if we need to set `--namespace <namespace>` for `kubectl apply/delete` commands
       # this should be set to `true` if the chart templates set `metadata.namespace`
       # (default: false)
       namespaceInTemplate: true
   ```

1. Run `make ensure` to pull all charts to local directory and extract values file for your clusters
   - This operation will copy files
     - from `charts/{<CHART_REPO>_,}<CHART_NAME>/<CHART_VERSION>/<base values file>`
     - to `clusters/<CLUSTER_NAME>/<namespace>.<name>[{<CHART_REPO>_,}<CHART_NAME>{,_<SUB_CHART_NAME>}@<CHART_VERSION>].yaml`
   - and will create directories `clusters/<CLUSTER_NAME>/manifests-custom/<namespace>.<name>` for post deployment manifests apply

1. Run `make gen` to generate all manifests for your environments after you have finished your customization on copied values files (run `make gen CLUSTER_NAME=<my-cluster-name>` to generate manifests for the specified cluster only)
   - This operation will generate all manifests for all charts required in `clusters/<CLUSTER_NAME>/manifests`

1. Run `make clean` to remove unused files

### Deployment Upgrade

This is a check list for your manual cluster deployment upgrades

- [ ] Add new values files by running `make ensure`
- [ ] __Commit__ new values files and changes
- [ ] Copy old values files content to these new values files
  - __IMPORTANT__: make sure no false override happen during this process (hint: inspect git diff carefully)
- [ ] __Commit__ these updated new values files
- [ ] Delete old values files by running `make clean`
- [ ] __Commit__ deletion of old values files

### Continuous Upgrade

Perform semi-automatic helm charts upgrade with renovate and pull requests

1. Enable renovate integration in this repo
1. Wait until or trigger renovate to update pull requests or issue dashboard (then approve necessary upgrades in the dashboard)
   - CI passed:
     - Chart not used: just merge it
     - Chart used: CI should fail in this case, check if there is any error in your ci script
   - CI failed:
     - Single CI job failed for chart upgrade pull requests:
       - Checkout the source branch (where chart was upgraded)
       - Update your cluster config and commit (see [Deployment Upgrade](#deployment-upgrade))
       - Push your new commit and request a review
     - Multiple CI jobs failed for chart upgrade pull requests:
       - Create a new branch
       - Merge all these upgrades (from their own branches)
       - Update your cluster config and commit (see [Deployment Upgrade](#deployment-upgrade))
       - Push your new branch, create a new pull request and request a review
1. Merge reviewed pull requests to your master branch

## LICENSE

```txt
Copyright 2020 The arhat.dev Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
