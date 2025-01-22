

编译 

```sh
docker build -t dovecot:0.0.1 .
```


```sh
docker run --rm --name dovecot \
-p 143:143 \
-p 993:993 \
dovecot:0.0.1
```