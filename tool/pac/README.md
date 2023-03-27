

使用 [genpac](https://github.com/JinnLynn/genpac) 生成:

需要先安装 genpac, 按照项目的说明安装即可。

比如：
```
pip install -i https://pypi.douban.com/simple genpac
```

```
genpac --pac-proxy="SOCKS5 127.0.0.1:1080" -o autoproxy_socks5_1080.pac --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" --user-rule-from user_rules.txt 
```

这里的 [gfwlist.txt](https://github.com/gfwlist/gfwlist/blob/master/gfwlist.txt) 文件`raw.githubuserconent.com`有可能也需要代理，可以手动下载到本地，然后使用 `--gfwlist-url - --gfwlist-local ./gfwlist.txt` 指定本地文件。

也可以设置下载 `gfwlist.txt`时使用代理：
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

也可以使用[pac_server.py](./pac_server.py)直接在本机启用一个 http 服务，然后使用本地文件，比如：
```
python pac_server.py
```
然后就可以使用`http://127.0.0.1:6789/autoproxy_socks5_1080.pac`作为PAC文件地址了。

另外注意， linux 系统的代理，设置 pac 时也需要填写一个 url， 而不是文件路径，文件路径可能会导致代理无法使用。


更多看： https://neucrack.com/p/80



