# Release processes

1. Update the `grafana/cortex-tools` image version in `Dockerfile`
1. Update the version in the examples displayed in `README.md`
1. Update the version in `CHANGELOG.md`
1. Create a new tag that follows semantic versioning:
   ```bash
   $ tag=v0.6.0
   $ git tag -s "${tag}" -m "${tag}"
   $ git push origin "${tag}"
   ```
1. Publish a new release in GitHub, including the `CHANGELOG.md` entries
