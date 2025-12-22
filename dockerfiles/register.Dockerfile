FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y curl bash && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /scripts
COPY scripts /scripts
COPY debezium /debezium

ENTRYPOINT ["bash", "/scripts/register-connectors.sh"]
