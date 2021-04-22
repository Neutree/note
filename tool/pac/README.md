

使用 [genpac](https://github.com/JinnLynn/genpac) 生成:

```
genpac --pac-proxy="SOCKS5 127.0.0.1:1080" -o autoproxy_socks5_1080.pac --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" --user-rule-from user_rules.txt 
```
设置下载 `gfwlist.txt`时使用代理：
```
genpac --pac-proxy="SOCKS5 127.0.0.1:1080" -o autoproxy_socks5_1080.pac --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" --user-rule-from user_rules.txt  --gfwlist-proxy="SOCKS5 127.0.0.1:1080" 
```

如果浏览器使用switchOmega 插件， PAC 网址可以直接填这里的地址

1088端口：
```
https://raw.githubusercontent.com/Neutree/note/master/tool/pac/autoproxy_socks5_1088.pac
```
1080端口：
```
https://raw.githubusercontent.com/Neutree/note/master/tool/pac/autoproxy_socks5_1080.pac
```

更多看： https://neucrack.com/p/80



