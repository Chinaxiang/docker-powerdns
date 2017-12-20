# docker-powerdns

PowerDNS + Admin GUI in one single Docker

使用mysql作为后端存储，请另外安装mysql.

## Configuration options

See [Dockerfile](Dockerfile)

## How to use

```
docker run \
    -d \
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