#!/bin/sh

# Notification of Check
ME="reQphxR0nOG8hqNnoQ85Rxk85Uv9EPvuKD2hguShVtI"
GROUP="mBZsRyVzb2I9UmSuk5ctLX6VIF9V1PqJsjxeaQMXcnZ"

TARGET=$ME

MSG="%0D%0AHourly check done!"
curl -H "Authorization: Bearer $TARGET" -d "message=$MSG" -X POST https://notify-api.line.me/api/notify; echo