# rust-shadowsocks docker 部署

这个部署用到了 `v2ray-plugin` 和 `nginx` 分流.需要先编译后再运行。

## 编译

编译依赖 `DOMAIN` , `PORT` 和 `PASSWORD`变量.

1. 变更可以写在`.env`文件中,使用 build.sh 脚本打包.该方法会随机生成 PASSWORD。
2. 手动部打包

```sh
# 脚本打包
./build.sh

# 手动打包
docker build --build-arg PORT=8388 -t shadowsocks .
```

## 启动

```sh

docker run -it --rm \
  --network shared-net \
  --name shadowsocks \
  -e DOMAIN=viweei.me \
  -e PASSWORD="" \
  -p 8388:8388 \
  shadowsocks:latest
```
