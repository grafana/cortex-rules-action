FROM grafana/cortextool:2020_format_diff-9bce61d

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
