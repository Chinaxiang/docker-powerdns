# docker-powerdns

PowerDNS + Admin GUI + Sqllite in one single Docker

## Configuration options

See [Dockerfile](Dockerfile)

## Docker images

> Docker Hub

```
docker pull chinaxiang/docker-powerdns
```

> Aliyun Hub

```
docker pull registry.cn-hangzhou.aliyuncs.com/chinaxiang/docker-powerdns
```

## How to use

### Simple

```
docker run \
    -d \
    -p 53:53 \
    -p 53:53/udp \
    -p 8080:8080 \
    registry.cn-hangzhou.aliyuncs.com/chinaxiang/docker-powerdns
```

### Advanced

```
docker run \
    --restart=always \
    -d \
    -e "API_KEY=my-awesome-api-key" \
    -p 53:53 \
    -p 53:53/udp \
    -p 8080:8080 \
    -p 8081:8081 \
    -v "/home/user/data:/srv/data" \
    registry.cn-hangzhou.aliyuncs.com/chinaxiang/docker-powerdns
```