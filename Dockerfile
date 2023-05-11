FROM grafana/cortex-tools:v0.10.6
FROM ubuntu:22.04

COPY /etc/ssl/certs/int.coresci.ca.pem /etc/ssl/certs

RUN apt-get -qq update \
    && apt-get -qq install -y ca-certificates \
    && update-ca-certificates && cp /etc/ssl/certs/* /tmp/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
