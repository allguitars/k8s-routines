FROM alpine

ENV LINE_TOKEN_ME reQphxR0nOG8hqNnoQ85Rxk85Uv9EPvuKD2hguShVtI
ENV LINE_TOKEN_GROUP mBZsRyVzb2I9UmSuk5ctLX6VIF9V1PqJsjxeaQMXcnZ
ENV LINE_NOTIFY_TARGET $LINE_TOKEN_GROUP

# Install curl
RUN set -ex; apk add curl

# Install kubectl
RUN set -ex; \
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl; \
  chmod +x ./kubectl; \
  mv ./kubectl /usr/local/bin/kubectl; \
  kubectl version --client

# Handling kubeconfig
ARG CONFIG
RUN set -ex; \
  mkdir /root/.kube; \
  echo "$CONFIG" >> /root/.kube/config
ENV KUBECONFIG /root/.kube/config

# EnSaaS login crendentials
ARG ENSAAS_USER
ARG ENSAAS_PASSWORD
ENV ENSAAS_USER $ENSAAS_USER
ENV ENSAAS_PASSWORD $ENSAAS_PASSWORD

# Script for adding crontab job inside the container instead of copying root over
# This is to avoid Windows line break issue
COPY ./scripts/startup.sh /usr/local/startup.sh
RUN set -ex; chmod 0744 /usr/local/startup.sh

## ------ 6-hourly routines ------
WORKDIR /etc/periodic/6hr
COPY ./scripts/namespace_stats_regular ./
RUN set -ex; chmod 0744 *

## ------ hourly routines ------
WORKDIR /etc/periodic/hourly
COPY ./scripts/hourly_check ./
RUN set -ex; chmod 0744 *

## ----- midnight cleanup ------
WORKDIR /etc/periodic/midnight
COPY ./scripts/remove_bad_pods ./
RUN set -ex; chmod 0744 *

## ----- Quote of the day ------
WORKDIR /etc/periodic/quote
COPY ./scripts/get_quote ./
RUN set -ex; chmod 0744 *

RUN set -ex; \
  apk add jq; \
  apk add bc

# Set system timezone
RUN set -ex; apk add tzdata && \
  cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
  echo "Asia/Taipei" > /etc/timesone

CMD ["sh", "-c", "/usr/local/startup.sh && crond -f"]
# CMD ["crond", "-f"]