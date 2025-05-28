#!/bin/sh

# Script to update DNSCrypt blocklist
# Downloads latest domain list and replaces blocklist.txt content after line 345
# Info: https://www.snbforums.com/threads/script-auto-update-dnscrypt-blocklist.94813/

# Define file paths
BLOCKLIST="/jffs/addons/dnscrypt/blocked-names.txt"  # blocklist location
BACKUP_FILE="${BLOCKLIST}.backup"  # Fixed backup name (will overwrite previous backup)
DOWNLOADED_FILE="/jffs/addons/dnscrypt/oisd_big_domainswild.txt"

# Create a backup first (overwriting any previous backup)
cp "$BLOCKLIST" "$BACKUP_FILE"
if [ $? -ne 0 ]; then
    echo "Failed to create backup on $(date)" >> /jffs/addons/dnscrypt/update_dnscrypt.log
    exit 1
fi

# Download the latest blocklist
curl -s -o "$DOWNLOADED_FILE" "https://big.oisd.nl/domainswild"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download blocklist on $(date)" >> /jffs/addons/dnscrypt/update_dnscrypt.log
    exit 1
fi

# Delete everything in blocklist.txt after line 345 and append downloaded content
sed -i '346,$d' "$BLOCKLIST"
cat "$DOWNLOADED_FILE" >> "$BLOCKLIST"

# Reload DNSCrypt (uneeded after 2.1.9 if Hot-reloading is enabled, changes apply instantly)
#/jffs/dnscrypt/manager dnscrypt-start

echo "DNSCrypt blocklist updated successfully on $(date)" >> /jffs/addons/dnscrypt/update_dnscrypt.log
