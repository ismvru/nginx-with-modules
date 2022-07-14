#!/bin/bash
set -e
SCRIPT_PATH=$(readlink -f "$0")
echo "GeoIP2 Cron ${SCRIPT_PATH}"

# Exit if we can't find needed variables
if [[ -z "${MM_USE_UPDATER}" ]]; then
    echo "Env variable MM_USE_UPDATER isn't set. Exiting..."
    exit 0
fi

if [[ -z "${MM_ACCOUNT_ID}" ]]; then
    echo "Env variable MM_ACCOUNT_ID isn't set. Exiting..."
    exit 0
fi

if [[ -z "${MM_LICENSE_KEY}" ]]; then
    echo "Env variable MM_ACCOUNT_ID isn't set. Exiting..."
    exit 0
fi

if [[ -z "${MM_EDITIONS}" ]]; then
    echo "Env variable MM_ACCOUNT_ID isn't set. Exiting..."
    exit 0
fi

if [[ -z "${MM_CRON}" ]]; then
    echo "Env variable MM_ACCOUNT_ID isn't set. Exiting..."
    exit 0
fi

# Add crontab entry and start cron
echo "Adding crontab entry"
crontab -l | {
    cat
    echo "${MM_CRON} ${SCRIPT_PATH}"
} | crontab -

echo "Start cron"
cron &
