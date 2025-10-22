#!/usr/bin/env bash
# send.sh - Simple Postfix sender
# Sends f.html to all emails in p.txt using local Postfix (sendmail interface)

set -euo pipefail

# --- Default configuration ---
FROM_ADDR="Skinny@Loss-Weight.us" 
SUBJECT="Skinny Shot (Ozempic) Weight"
BODY_FILE="f.html"
LIST_FILE="11M.txt" 
SENDMAIL_BIN="/usr/sbin/sendmail"

# --- Checks ---
[ -x "$SENDMAIL_BIN" ] || { echo "sendmail not found at $SENDMAIL_BIN"; exit 1; }
[ -f "$BODY_FILE" ] || { echo "$BODY_FILE not found"; exit 1; }
[ -f "$LIST_FILE" ] || { echo "$LIST_FILE not found"; exit 1; }

# --- Clean and prepare list ---
TMP_LIST="$(mktemp)"
trap 'rm -f "$TMP_LIST"' EXIT

awk 'NF{gsub(/\r/,""); print}' "$LIST_FILE" \
  | sed 's/^[ \t]*//;s/[ \t]*$//' \
  | awk '!seen[$0]++' > "$TMP_LIST"

TOTAL=$(wc -l < "$TMP_LIST")
echo "Starting to send to $TOTAL recipients..."

# --- Send loop ---
count=0
while IFS= read -r to_addr; do
  [[ -z "$to_addr" ]] && continue

  # validate email format (basic)
  if ! [[ "$to_addr" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Skipping invalid: $to_addr"
    continue
  fi

  {
    echo "From: $FROM_ADDR"
    echo "To: $to_addr"
    echo "Subject: $SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/html; charset=UTF-8"
    echo
    cat "$BODY_FILE"
  } | "$SENDMAIL_BIN" -i -f "$FROM_ADDR" -- "$to_addr"

  ((count++))
  echo "Sent [$count/$TOTAL]: $to_addr"

done < "$TMP_LIST"

echo "All done. Total sent: $count"
