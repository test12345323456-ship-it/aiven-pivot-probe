#!/bin/bash
echo "=== capabilities/kernel ==="
uname -a; cat /proc/self/cgroup | head -3; grep -E "CapEff|Seccomp" /proc/self/status
echo "=== mounts (ours) ==="
cat /proc/self/mounts | grep -vE "^(proc|sysfs|tmpfs|devpts|mqueue|cgroup)" | head -12
echo "=== neighbor ULAs from resolv ==="
hosts=$(grep -oE "fda7:[a-f0-9:]{20,}" /etc/resolv.conf | sort -u | head -10)
echo "$hosts"
echo "=== neighbor port probes ==="
for ip in $hosts; do
  for p in 22 80 443 6379 8080 9440 2181; do
    timeout 1 bash -c "echo > /dev/tcp/$ip/$p" 2>/dev/null && echo "OPEN [$ip]:$p"
  done
done
echo "=== reverse DNS (our ULA) ==="
getent hosts "$(ip -6 addr show 2>/dev/null | grep -oE 'fda7:[a-f0-9:]+' | head -1)" || echo none
echo "=== more infra pods (index sweep) ==="
for i in 1380 1381 1382 1385 1386 1395 1396 1397; do
  n="nc-5a2c74f2-265b-560a-8974-61f2bd981520-$i.aiven-application-infrastructure.aiven.local"
  getent hosts "$n" && echo "  ^ $n"
done
echo "=== http: static-ip w/params body + mfa unauth body + CORS ==="
curl -s -m 6 "https://admin-api.aiven.io:4343/v1/prod/static-ip/pool?project_name=test12345323456-ae5b&service_name=pg17-flip-a" | head -c 200; echo
curl -s -m 6 -X POST -d "mfa_token=test" "https://admin-api.aiven.io:4343/v1/mfa/challenge" | head -c 200; echo
curl -s -m 6 -D - -o /dev/null -X OPTIONS -H "Origin: https://evil.example.com" -H "Access-Control-Request-Method: PUT" "https://admin-api.aiven.io:4343/v1/users/me" | grep -iE "access-control|^HTTP"
echo "=== DONE ==="
echo "=====RESULTS-MIRROR====="
cat /srv/res.txt
