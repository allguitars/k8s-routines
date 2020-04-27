FROM alpine

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
COPY ./startup.sh /usr/local/startup.sh
RUN set -ex; chmod 0744 /usr/local/startup.sh

# 6-hour folder
WORKDIR /etc/periodic/6hr
# 6-hour scripts
COPY ./namespace_stats_regular.sh ./
# Set permission
RUN set -ex; chmod 0744 *

# Install tools (curl already installed in ensaas/kubectl-alpine)
RUN set -ex; \
  apk add jq; \
  apk add bc

CMD ["sh", "-c", "/usr/local/startup.sh && crond -f"]
# CMD ["crond", "-f"]