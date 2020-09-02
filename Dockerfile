FROM owend/cortextool:loki-loading-012153a

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
