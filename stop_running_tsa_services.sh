#!/bin/bash

# Database connection details
DB_HOST="T24-DB"
DB_USER="t24"
DB_NAME="BANCA"
DB_PASSWORD="Yr@dNwcvZ&Mz"

# TAFJ REST endpoint details
TAFJ_URL="http://localhost:8080/TAFJRestServices/resources/ofs"
AUTH_HEADER="Authorization: Basic dGFmai5hZG1pbjpBWElAZ3RwcXJYNA=="
CONTENT_TYPE="content-type: application/json"

# OFS credentials (replace if needed)
SIGNON="IGGI01/123123123"

echo "🔍 Fetching TSA services that are NOT stopped..."

# Get the list of active service record IDs
recids=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -A -c \
"SELECT recid FROM public.\"F_TSA_SERVICE\" WHERE COALESCE((xmlrecord::json)->>'6','') <> 'STOP';")

if [[ -z "$recids" ]]; then
  echo "✅ All TSA services are already stopped."
  exit 0
fi

echo "🛑 Found active services:"
echo "$recids"
echo

# Loop through each record
for recid in $recids; do
  echo "➡️ Stopping service: $recid"

  # Replace slashes with carets for OFS compatibility
  safe_recid=$(echo "$recid" | tr '/' '^')

  # Build OFS command
  ofs="TSA.SERVICE,STOP/I/PROCESS,$SIGNON,$safe_recid"

  # Send the request
  curl -s -X POST "$TAFJ_URL" \
    -H "$AUTH_HEADER" \
    -H "cache-control: no-cache" \
    -H "$CONTENT_TYPE" \
    -d "{\"ofsRequest\":\"$ofs\"}" | jq . 2>/dev/null

  echo "✅ Sent STOP command for $recid"
  echo "--------------------------------------"
done

echo "🎯 All non-stopped TSA services have been issued STOP commands."

