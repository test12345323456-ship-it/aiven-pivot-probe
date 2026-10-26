FROM alpine:3.19
RUN apk add --no-cache curl python3 bash
COPY probe.sh /probe.sh
RUN chmod +x /probe.sh
EXPOSE 8080
CMD ["/bin/bash","-c","/probe.sh > /srv/res.txt 2>&1; cd /srv && python3 -m http.server 8080"]
