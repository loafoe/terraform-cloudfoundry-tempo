FROM grafana/tempo:1.4.1 AS tempo
COPY tempo.yaml /etc/tempo.yaml
EXPOSE 3100

## Build tempo
FROM alpine:3.16.2 AS tempo2
ARG tempo_version
ENV TEMPO_VERSION ${tempo_version}
RUN apk add --no-cache curl
WORKDIR /app
RUN curl -L -Os https://github.com/grafana/tempo/releases/download/v${TEMPO_VERSION}/tempo_${TEMPO_VERSION}_linux_amd64.tar.gz \
 && tar zxvf tempo_${TEMPO_VERSION}_linux_amd64.tar.gz --strip 1

## Build final image
FROM alpine:3.16.2
LABEL maintainer="andy.lo-a-foe@philips.com"
RUN apk add --no-cache supervisor jq curl && rm -rf /tmp/* /var/cache/apk/*
RUN apk add --no-cache yq --repository http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN mkdir -p /sidecars/bin /sidecars/supervisor/conf.d sidecars/etc /tempo

COPY --from=tempo     /tempo     /sidecars/bin

COPY supervisord_configs/ /sidecars/supervisor/conf.d
COPY scripts/ /sidecars/bin

EXPOSE 3100

COPY supervisord.conf /etc/
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
