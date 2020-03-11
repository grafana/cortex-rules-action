# Cortextool Sync/Diff Github Action

This action is used to sync rules to a [Cortex](https://github.com/cortexproject/cortex) cluster.

## Environment Variables

This action is configured using environment variables defined in the workflow job. The following variables can be configured.

| Name               | Description                                                                                                                                                                                                                                | Required | Default |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `CORTEX_ADDRESS`   | URL address for the target Cortex cluster                                                                                                                                                                                                  | `true`   | N/A     |
| `CORTEX_TENANT_ID` | ID for the desired tenant in the target Cortex cluster                                                                                                                                                                                     | `true`   | N/A     |
| `CORTEX_API_KEY`   | Optional password that is required for password protected Cortex clusters. An encrypted github secret is recommended. https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets | `false`  | N/A     |
| `ACTION`           | Action to take when syncing rules. Either `diff` or `sync`.                                                                                                                                                                                | `false`  | `diff`  |
| `RULES_DIR`        | Comma-separated list of directories to walk in order to source rules files.                                                                                                                                                                | `false`  | `./`    |

## Actions

### `diff`

Running the action with the `diff` command will crawl the specified `RULES_DIR` for Prometheus rules files with a `yaml`/`yml` extension and output the differences in the configured files and the currently configured ruleset in a Cortex cluster. It will output the required operations in order to make the running Cortex cluster match the rules configured in the directory. It will **not create/update/delete any rules** currently running in the Cortex cluster.

### `sync`

Running the action with the `diff` command will crawl the specified `RULES_DIR` for `yaml`/`yml` Prometheus rules files and reconcile the differences with the sourced rules and the rules currently running in a configured Cortex cluster. It **will create/update/delete rules** currently running in Cortex to match what is configured in the files in the provided directory.

## Outputs

### `summary`

The `summary` output variable returned by this action is a string denoting the number of rule groups either created/updated/deleted. If the action is set to `diff`, these values are only hypothetical.

### `detailed`

The `detailed` output variable returned by this action is the full output of the command.

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
          ACTION: diff
          RULES_DIR: "./rules/" # In this example rules are stored in a rules directory in the repo 
```
