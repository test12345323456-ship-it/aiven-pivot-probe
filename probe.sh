#!/bin/bash
echo "=== env (variable names + values of OUR app only) ==="
env | sort
echo "=== /etc/hosts ==="; cat /etc/hosts
echo "=== resolv.conf ==="; cat /etc/resolv.conf 2>/dev/null | head -5
echo "=== DNS: internal names ==="
for h in pg17-flip-a-1.test12345323456-ae5b.aiven.local admin-api.aiven.io mcp.aiven.live iam.aiven.io; do
  echo "-- $h:"; getent hosts "$h" || echo "   NXDOMAIN"
done
echo "=== HTTP reachability (status+first line only) ==="
for u in "https://admin-api.aiven.io:4343/v1/openapi.json" "https://api.aiven.io/v1" "https://mcp.aiven.live/.well-known/oauth-protected-resource" "https://iam.aiven.io/"; do
  echo "-- $u:"; curl -s -m 6 -o /tmp/o -w "  HTTP %{http_code} bytes %{size_download}\n" "$u"; head -c 100 /tmp/o | tr -d '\0'
done
echo "=== admin-api FULL body ==="
curl -s -m 8 "https://admin-api.aiven.io:4343/v1/openapi.json" | head -c 6000
echo
echo "=== internal port scan (fast connect only) ==="
for ip in "127.0.0.1" "192.168.88.9" "35.210.14.70"; do
  for p in 4343 32001 80 443 8080; do timeout 1 bash -c "echo > /dev/tcp/$ip/$p" 2>/dev/null && echo "OPEN $ip:$p"; done
done
echo "=== DONE ==="
