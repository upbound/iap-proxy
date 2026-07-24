FROM alpine:3.24

RUN apk --update upgrade && \
    apk add curl ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

ADD ./out/iap_auth /iap_auth

ENV PORT=8088 \
	LOGGER_LEVEL=INFO \
  REFRESH_TIME_SECONDS= \
	IAP_HOST= \
	SERVICE_ACCOUNT_CREDENTIALS= \
	CLIENT_ID=
EXPOSE ${PORT}
CMD /iap_auth