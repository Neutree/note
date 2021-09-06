

## 获得 docker 镜像

可以从 `Dockerfile` 构建

```
docker build -t dst_server .
```

也可以直接从 dockerhub 拉取：

```
docker pull neucrack/dst_server
```

## 申请 key


[klei 官网](https://accounts.klei.com/) 申请一个 key， 设置好房间， 点击下载， 会获得一个压缩文件， 解压后得到`MyDediServer`文件夹：

```
MyDediServer
├── Caves
│      └── server.ini
├── Master
│      └── server.ini
├── cluster.ini
├── cluster_token.txt
```

## 添加 mod

在这个文件夹的基础上添加了几个文件， 最后得到：

```
MyDediServer
├── Caves
│      ├── save
│      ├── server.ini
│      ├── worldgenoverride.lua
│      └── modoverrides.lua
├── Master
│      ├── save
│      ├── server.ini
│      ├── worldgenoverride.lua
│      └── modoverrides.lua
├── cluster.ini
├── cluster_token.txt
├── dedicated_server_mods_setup.lua
└── modsettings.lua
```

这里主要两个文件:
* `dedicated_server_mods_setup.lua`: 下载哪些插件
* `modoverrides.lua` : 房间启用哪些插件

有一个比较好用的方法就是在工坊订阅 mod， 然后在游戏里新建房间， 勾选 mod 并配置， 生成游戏房间， 然后从游戏的配置文件复制过来:
* 在`C:/User/用户名/.klei/DoNotStarveTogether/账户id/房间号` 文件夹下找到`modoverrides.lua`配置
* steam 游戏右键属性，打开文件路径， 找到`mods`文件夹中的`dedicated_server_mods_setup.lua`

另外还有`modsettings.lua`和 `worldgenoverride.lua`分别是设置`mod`（比如强制启用`mod`），和设置地图和资源等的参数


## 保存进度

运行后在 `Master` 和 `Caves` 下有`save` 和`backup` 文件夹， 复制保存下次覆盖`save`文件夹即可



## 创建服务器 docker 容器

获取需要开放的端口（在这三个 ini 配置文件中）, 可以利用这里的`get_ports.py`脚本获取
```
ports=`python3 get_ports.py ./MyDediServer`
echo $ports
```


服务器保证这些端口开放，关闭防火墙或者设置这些端口为白名单， 可以把 TCP 和 UDP 都打开
> 比如用了 `ufw`, 则 `ufw allow 端口号`
> iptable: 
> iptables -A INPUT -p udp --dport 端口号 -j ACCEPT
> iptables -A OUTPUT -p udp --sport 端口号 -j ACCEPT

替换下面命令的端口号映射并执行

```
cd MyDediServer

docker run --name dst_server_1 -v `pwd`:/root/.klei/DoNotStarveTogether/room -p 10889:10889 -p 11000:11000 -p 11001:11001 dst_server
```


run 命令会自动启动服务器， 可以看 log 是否成功， 也可以在游戏大厅搜索设置的名字， 成功后 `ctrl+c` 退出

## 启动容器（服务器）

```
docker start dst_server_1
```

## 停止

```
docker stop dst_server_1
```

## 查看启动日志

```
docker logs dst_server_1
```


## 开机自启

```
docker update --restart=always dst_server_1
systemctl enable docker
```


