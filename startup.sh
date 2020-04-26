#!/bin/sh

echo "Running startup.sh.."

# Crontab
echo -e "0       */6     *       *       *       /etc/periodic/6hr/namespace_stats_regular.sh\n" >> /etc/crontabs/root
crontab -l

# Greeting
ME="reQphxR0nOG8hqNnoQ85Rxk85Uv9EPvuKD2hguShVtI"
GROUP="mBZsRyVzb2I9UmSuk5ctLX6VIF9V1PqJsjxeaQMXcnZ"

TARGET=$GROUP
MSG="%0D%0AThe k8s-routines container has started."
curl -H "Authorization: Bearer $TARGET" -d "message=$MSG" -X POST https://notify-api.line.me/api/notify; echo
