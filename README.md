# docker-powerdns

PowerDNS + Admin GUI in one single Docker

Use MySQL as backend, please install MySQL before you use this images.

![](http://ww4.sinaimg.cn/large/a15b4afely1fmpq3umk45j21h90ksach)

![](http://ww4.sinaimg.cn/large/a15b4afegy1fmpq5j6cp5j21h50g2myr)

## Configuration options

See [Dockerfile](Dockerfile)

## Docker images

> Docker Hub

```
docker pull chinaxiang/docker-powerdns:mysql
```

> Aliyun Hub

```
docker pull registry.cn-hangzhou.aliyuncs.com/chinaxiang/docker-powerdns:mysql
```

## How to use

```
docker run \
    -d \
    -e "API_KEY=my-api-key" \
    -e "MYSQL_AUTOCONF=true" \
    -e "MYSQL_HOST=10.255.1.101" \
    -e "MYSQL_USER=root" \
    -e "MYSQL_PWD=root3306" \
    -p 53:53 \
    -p 53:53/udp \
    -p 8080:8080 \
    -p 8081:8081 \
    registry.cn-hangzhou.aliyuncs.com/chinaxiang/docker-powerdns:mysql
```