#!/bin/sh

echo "Running startup.sh.."

# Crontab
echo -e "0       */6     *       *       *       run-parts /etc/periodic/6hr\n" >> /etc/crontabs/root
echo -e "0       0       *       *       *       run-parts /etc/periodic/midnight\n" >> /etc/crontabs/root
echo -e "0       8       *       *       *       run-parts /etc/periodic/quote\n" >> /etc/crontabs/root
crontab -l

# Greeting
MSG="%0D%0AThe k8s-routines container has started."
curl -H "Authorization: Bearer $LINE_NOTIFY_TARGET" -d "message=$MSG" -X POST https://notify-api.line.me/api/notify; echo



### min   hour    day     month   weekday command
# */15    *       *       *       *       run-parts /etc/periodic/15min
# 0       *       *       *       *       run-parts /etc/periodic/hourly
# 0       2       *       *       *       run-parts /etc/periodic/daily
# 0       3       *       *       6       run-parts /etc/periodic/weekly
# 0       5       1       *       *       run-parts /etc/periodic/monthly

# 0       */6     *       *       *       run-parts /etc/periodic/6hr
# 0       0       *       *       *       run-parts /etc/periodic/midnight
# 0       8       *       *       *       run-parts /etc/periodic/quote
