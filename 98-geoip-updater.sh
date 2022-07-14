#!/bin/bash
set -e
SCRIPT_PATH=$(readlink -f "$0")
echo "GeoIP2 Updater ${SCRIPT_PATH}"

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

# Generate GeoIP.conf
envsubst </etc/GeoIP.conf.template >/etc/GeoIP.conf

# Force update if can't find any mmdb files in /var/lib/GeoIP/
if [[ ! $(find /var/lib/GeoIP/ -type f -name "*.mmdb" -print) ]]; then
    echo "Can't find GeoIP2 Databases. Updating..."
    geoipupdate -v
fi

# Update if mmdb files in /var/lib/GeoIP/ is too old
if [[ $(find /var/lib/GeoIP/ -type f -name "*.mmdb" -mtime +7 -print) ]]; then
    echo "GeoIP2 Databases is too old. Updating"
    geoipupdate -v
fi

# List databases
echo "Existing GeoIP2 databases: "
ls -la /var/lib/GeoIP/
