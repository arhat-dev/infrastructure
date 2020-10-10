# Infrastructure

[![CI](https://github.com/arhat-dev/infrastructure/workflows/CI/badge.svg)](https://github.com/arhat-dev/infrastructure/actions?query=workflow%3ACI)

Create service infrastructure on top of Kubernetes for daily development

## Prerequisites

- `docker` to run `helm-stack`
- GNU `make`

## Workflow

### Before you start

Create a private repo with this template to avoid any credential leak.

### Initial service provision

1. Add or update repo/chart references in [`.helm-stack`](./.helm-stack)
2. Define your clusters in [`.helm-stack.yaml`](./.helm-stack.yaml)
3. Run `make ensure` to pull all charts to local directory and extract values file for your clusters

### Continuous service upgrade (upgrade helm charts)

1. Add or update repo/chart references in [`.helm-stack`](./.helm-stack)
2. Update cluster deployments in [`.helm-stack.yaml`](./.helm-stack.yaml)
   - Usually you should not change the deployment name
3. Run `make ensure` to make sure everything up to date
   - DO NOT CHANGE anything in values files at this step

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
