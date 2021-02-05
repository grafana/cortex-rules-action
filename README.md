# Cortextool Github Action

This action is used to lint, prepare, verify, diff, and sync rules to a [Cortex](https://github.com/cortexproject/cortex) cluster.

## Environment Variables

This action is configured using environment variables defined in the workflow. The following variables can be configured.

| Name               | Description                                                                                                                                                                                                                                | Required | Default |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `CORTEX_ADDRESS`   | URL address for the target Cortex cluster                                                                                                                                                                                                  | `false`  | N/A     |
| `CORTEX_TENANT_ID` | ID for the desired tenant in the target Cortex cluster. Used as the username under HTTP Basic authentication.                                                                                                                                                                                     | `false`  | N/A     |
| `CORTEX_API_KEY`   | Optional password that is required for password-protected Cortex clusters. An encrypted [github secret](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets ) is recommended. Used as the password under HTTP Basic authentication. | `false`  | N/A     |
| `ACTION`           | Which action to take. One of `lint`, `prepare`, `check`, `diff` or `sync`                                                                                                                                                                  | `true`   | N/A     |
| `RULES_DIR`        | Comma-separated list of directories to walk in order to source rules files                                                                                                                                                                 | `false`  | `./`    |
|	`COMPONENT`		 | `RULER` or `ALERTMANAGER`. This dictates whether to sync ruler rulegroups or AlertManager configurations	| `true`	|	N/A		|
| `ALERTMANAGER_CONFIG_PATH` | Path to the tenants AlertManager configuration | `true` If `COMPONENT` is set to `ALERTMANAGER` | `./alertManager.yml`

## Authentication

This GitHub Action uses [`cortextool`](https://github.com/grafana/cortex-tools) under the hood, `cortextool` uses HTTP Basic authentication against a Cortex cluster. The variable `CORTEX_TENANT_ID` is used as the username and `CORTEX_API_KEY` as the password.

## Actions

All actions will crawl the specified `RULES_DIR` for Prometheus rules and alerts files with a `yaml`/`yml` extension.

### `diff`

Outputs the differences in the configured files and the currently configured ruleset in a Cortex cluster. It will output the required operations in order to make the running Cortex cluster match the rules configured in the directory. It will **not create/update/delete any rules** currently running in the Cortex cluster.

### `sync`

Reconcile the differences with the sourced rules and the rules currently running in a configured Cortex cluster. It **will create/update/delete rules** currently running in Cortex to match what is configured in the files in the provided directory.

### `lint`

Lints a rules file(s). The linter's aim is not to verify correctness but to fix YAML and PromQL expression formatting within the rule file(s). The linting happens in-place within the specified file(s). Does not interact with your Cortex cluster.

### `prepare`
Prepares a rules file(s) for upload to Cortex. It lints all your PromQL expressions and adds a `cluster` label to your PromQL query aggregations in the file. Prepare modifies the file(s) in-place. Does not interact with your Cortex cluster.

### `check`

Checks rules file(s) against the recommended [best practices](https://prometheus.io/docs/practices/rules/) for rules. Does not interact with your Cortex cluster.

### `print`

fetch & print rules from the Cortex cluster.

## Outputs

### `summary`

The `summary` output variable is a string denoting the output summary of the action, if there is one.

### `detailed`

The `detailed` output variable returned by this action is the full output of the command executed.

## Example Workflows

### Pull Request Diff

The following workflow will run a diff on every pull request against the repo and print the summary as a comment in the associated pull request:

```yaml
name: diff_rules_pull_request
on: [pull_request]
jobs:
  diff-pr:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Diff Rules
        id: diff_rules
        uses: grafana//cortex-rules-action@v0.1.1
        env:
          CORTEX_ADDRESS: https://example-cluster.com/
          CORTEX_TENANT_ID: 1
          CORTEX_API_KEY: ${{ secrets.CORTEX_API_KEY }} # Encrypted Github Secret https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets
          ACTION: diff
          RULES_DIR: "./rules/" # In this example rules are stored in a rules directory in the repo
      - name: comment PR
        uses: unsplash/comment-on-pr@v1.2.0 # https://github.com/unsplash/comment-on-pr
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          msg: "${{ steps.diff_rules.outputs.summary }}" # summary could be replaced with detailed for a more granular view
```

### Master Sync

The following workflow will sync the rule files in the `master` branch with the configured Cortex cluster.

```yaml
name: sync_rules_master
on:
 push:
   branches:
     - master
jobs:
  sync-master:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          ref: master
      - name: sync-rules
        uses: grafana//cortex-rules-action@v0.1.1
        env:
          CORTEX_ADDRESS: https://example-cluster.com/
          CORTEX_TENANT_ID: 1
          CORTEX_API_KEY: ${{ secrets.CORTEX_API_KEY }} # Encrypted Github Secret https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets
          ACTION: sync
          RULES_DIR: "./rules/" # In this example rules are stored in a rules directory in the repo
```

The following workflow will sync the AlertManager configuration file in the `master` branch against the configured Cortex cluster
```yaml
name: sync_alertmanager_master
on:
 push:
   branches:
     - master
jobs:
  sync-master:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          ref: master
      - name: sync-alertmanager
        uses: grafana//cortex-rules-action@v0.1.1
        env:
          CORTEX_ADDRESS: https://example-cluster.com/
          CORTEX_TENANT_ID: 1
          CORTEX_API_KEY: ${{ secrets.CORTEX_API_KEY }} # Encrypted Github Secret https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets
          ACTION: sync
          COMPONENT: ALERTMANAGER
          ALERTMANAGER_CONFIG_PATH: "./alertmanager/config.yml" # In this example the AlertManager config is stored in the `alertmanager/` directory in the repository```
