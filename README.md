# docker-powerdns

PowerDNS + Recursor + Admin GUI + Adblock in one single Docker

## Configuration options

See [Dockerfile](Dockerfile#L9)

## Ad-Block feature

If you want to enable ad-blocking on top of your entries, just set the [relative environment variable](Dockerfile#L27) to `true`. List courtesy of [Pi-Hole project](https://pi-hole.net/).

The list will be updated using cron, at the time specified on the [relative environment variable](Dockerfile#L24).

## How to use

### Simple

```
docker run \
    --restart=always \
    -d \
    -p 53:53 \
    -p 53:53/udp \
    -p 80:8080 \
    chinaxiang/docker-powerdns
```

### Advanced

```
docker run \
    --restart=always \
    -d \
    -e "CUSTOM_DNS=8.8.8.8;8.8.4.4;[2001:4860:4860::8888];[2001:4860:4860::8844]" \
    -e "API_KEY=my-awesome-api-key" \
    -e "CRONTAB_TIME=0 10 * * *" \
    -e "ENABLE_ADBLOCK=true" \
    -p 53:53 \
    -p 53:53/udp \
    -p 80:8080 \
    -v "/home/user/data:/srv/data" \
    chinaxiang/docker-powerdns
```