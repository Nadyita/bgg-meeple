#!/bin/sh
# Test script for BGG authentication and XML API2 access.
# Edit USERNAME and PASSWORD below, then run:
#   sh scripts/test_bgg_auth.sh

USERNAME="reidel"
PASSWORD="if2qEBorJNVw8FUe8ZP8KnhE"

LOGIN_URL="https://boardgamegeek.com/login/api/v1"
COLLECTION_URL="https://boardgamegeek.com/xmlapi2/collection?username=${USERNAME}&version=1&stats=1"
THING_URL="https://boardgamegeek.com/xmlapi2/thing?id=13&stats=1"

echo "=== Step 1: Login ==="
curl -s -D /tmp/login_headers.txt -o /tmp/login_body.json -w "HTTP %{http_code}\n" \
  -X POST \
  -H "Content-Type: application/json" \
  "$LOGIN_URL" \
  -d "{\"credentials\":{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}}"

echo "--- Login body ---"
cat /tmp/login_body.json
echo ""

echo "--- Set-Cookie headers ---"
grep -i "set-cookie" /tmp/login_headers.txt || echo "No set-cookie header"
echo ""

# Extract individual cookies
cp /tmp/login_headers.txt /tmp/login_cookies.txt
# Remove the "set-cookie: " prefix and keep the name=value part before the first ;
BGGUSER=$(grep -i "bggusername=" /tmp/login_headers.txt | grep -v "deleted" | head -1 | sed 's/.*bggusername=\([^;]*\);.*/\1/')
BGGPASS=$(grep -i "bggpassword=" /tmp/login_headers.txt | grep -v "deleted" | head -1 | sed 's/.*bggpassword=\([^;]*\);.*/\1/')
SESSIONID=$(grep -i "SessionID=" /tmp/login_headers.txt | grep -v "deleted" | head -1 | sed 's/.*SessionID=\([^;]*\);.*/\1/')

if [ -z "$SESSIONID" ]; then
  echo "ERROR: No SessionID cookie received. Login likely failed."
  exit 1
fi

ALL_COOKIES="bggusername=${BGGUSER}; bggpassword=${BGGPASS}; SessionID=${SESSIONID}"
SESSION_COOKIE="SessionID=${SESSIONID}"

echo "Extracted SessionID: $SESSIONID"
echo "All cookies: $ALL_COOKIES"
echo ""

echo "=== Step 2a: Collection with SessionID only ==="
curl -s -D /tmp/collection_session_headers.txt -o /tmp/collection_session.xml -w "HTTP %{http_code}\n" \
  -H "Cookie: $SESSION_COOKIE" \
  "$COLLECTION_URL"

echo "--- Collection (SessionID only) first 20 lines ---"
head -20 /tmp/collection_session.xml
echo ""

echo "=== Step 2b: Collection with all cookies ==="
curl -s -D /tmp/collection_all_headers.txt -o /tmp/collection_all.xml -w "HTTP %{http_code}\n" \
  -H "Cookie: $ALL_COOKIES" \
  "$COLLECTION_URL"

echo "--- Collection (all cookies) first 20 lines ---"
head -20 /tmp/collection_all.xml
echo ""
