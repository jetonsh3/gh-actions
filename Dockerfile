FROM alpine:3.21 AS build

WORKDIR /app

RUN apk --no-cache add ca-certificates && \
  addgroup -S ghactions && \
  adduser -S -G ghactions -u 10001 ghactions -s /bin/false

FROM scratch AS production

ARG SERVICE

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /etc/passwd /etc/passwd

COPY ${SERVICE} /service

USER ghactions

ENTRYPOINT ["/service"]
