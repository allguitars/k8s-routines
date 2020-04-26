FROM ensaas/kubectl-alpine

ENV PW $TOKEN

# Script for adding crontab job inside the container instead of copying root over
# This is to avoid Windows line break issue
COPY ./startup.sh /usr/local/startup.sh
RUN set -ex; chmod 0744 /usr/local/startup.sh

# min folder
# WORKDIR /etc/periodic/min
# min scripts
# COPY ./namespace_stats_regular.sh ./
# Set permission
# RUN set -ex; chmod 0744 *

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

# Key for creating a token
WORKDIR /root/store
COPY ./key.json ./

CMD ["sh", "-c", "/usr/local/startup.sh && crond -f"]
# CMD ["crond", "-f"]