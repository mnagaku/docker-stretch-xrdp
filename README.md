```
build.sh
```

で、コンテナイメージmnagaku/xrdpを作成し、

```
docker run -d -p 3389:3389 mnagaku/xrdp
```

で、実行し、RDPクライアントで、

* user:pass = xrdpuser:hogehoge

で接続する。
