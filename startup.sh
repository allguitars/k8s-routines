#!/bin/sh

echo "Running startup.sh.."

# Crontab
echo -e "0       */6     *       *       *       /etc/periodic/6hr/namespace_stats_regular.sh\n" >> /etc/crontabs/root
crontab -l

# Greeting
ME="reQphxR0nOG8hqNnoQ85Rxk85Uv9EPvuKD2hguShVtI"
GROUP="mBZsRyVzb2I9UmSuk5ctLX6VIF9V1PqJsjxeaQMXcnZ"

TARGET=$ME

MSG="%0D%0AThe k8s-routines container has started."
curl -H "Authorization: Bearer $TARGET" -d "message=$MSG" -X POST https://notify-api.line.me/api/notify; echo



### min   hour    day     month   weekday command
# */15    *       *       *       *       run-parts /etc/periodic/15min
# 0       *       *       *       *       run-parts /etc/periodic/hourly
# 0       2       *       *       *       run-parts /etc/periodic/daily
# 0       3       *       *       6       run-parts /etc/periodic/weekly
# 0       5       1       *       *       run-parts /etc/periodic/monthly

# 0       */6     *       *       *       /etc/periodic/6hr/namespace_stats_regular.sh