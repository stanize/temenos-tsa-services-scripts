#!/bin/bash

# Usage: ./stop_tsa_services.sh <TSA_SERVICE>
# Example: ./stop_tsa_services.sh TSA.SERVICE

# Exit if no parameter is provided
if [ -z "$1" ]; then
  echo "❌ Usage: $0 <TSA.SERVICE>"
  exit 1
fi

TSM_NAME="$1"

# Replace slashes with carets if any exist (for OFS compatibility)
TSM_ID_ESCAPED=$(echo "$TSM_NAME" | sed 's/\//^/g')

# Define variables
USER_ID="IGGI01"
SESSION_ID="123123123"
OFS_COMMAND="TSA.SERVICE,STOP/I/PROCESS,${USER_ID}/${SESSION_ID},${TSM_ID_ESCAPED}"
TAFJ_URL="http://localhost:8080/TAFJRestServices/resources/ofs"
AUTH_HEADER="Authorization: Basic dGFmai5hZG1pbjpBWElAZ3RwcXJYNA=="
CONTENT_TYPE="content-type: application/json"

echo "🟡 Sending STOP command for $TSM_NAME..."
echo "OFS Request: $OFS_COMMAND"
echo "--------------------------------------"

# Execute the curl command
response=$(curl -s -X POST "$TAFJ_URL" \
  -H "$AUTH_HEADER" \
  -H "cache-control: no-cache" \
  -H "$CONTENT_TYPE" \
  -d "{\"ofsRequest\":\"$OFS_COMMAND\"}")

# Show response
echo "✅ Response received:"
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "--------------------------------------"

