# Release processes

1. Update the `grafana/cortex-tools` image version in `Dockerfile`
2. Create a new tag that follows semantic versioning:

```bash
$ tag=v0.6.0
$ git tag -s "${tag}" -m "${tag}"
$ git push origin "${tag}"
```
