# docker-powerdns

PowerDNS + Recursor + Admin GUI + Adblock in one single Docker

使用mysql作为后端存储，请另外安装mysql.

## Configuration options

See [Dockerfile](Dockerfile#L9)

## Ad-Block feature

If you want to enable ad-blocking on top of your entries, just set the [relative environment variable](Dockerfile#L27) to `true`. List courtesy of [Pi-Hole project](https://pi-hole.net/).

The list will be updated using cron, at the time specified on the [relative environment variable](Dockerfile#L24).

## How to use

```
docker run \
    -d \
    -e "CUSTOM_DNS=114.114.114.114" \
    -e "API_KEY=my-api-key" \
    -e "MYSQL_HOST=10.255.1.101" \
    -e "MYSQL_USER=root" \
    -e "MYSQL_PWD=root3306" \
    -p 53:53 \
    -p 53:53/udp \
    -p 8080:8080 \
    -p 8081:8081 \
    registry.cn-hangzhou.aliyuncs.com/chinaxiang/docker-powerdns:mysql
```