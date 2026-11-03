FROM grafana/cortex-tools:v0.11.3@sha256:ed86004a3d5eb7a8351fd1fa9c2a8f4f70c6b133eb57846c55aef9e4f485da0c

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
