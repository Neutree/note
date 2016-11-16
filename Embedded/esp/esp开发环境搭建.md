esp开发环境搭建
====

# 一：使用docker
> 请先了解[什么是docker](../../docker/doc/what-docker.md)


## (一） 安装docker

<a href="https://docs.docker.com/engine/installation/" target="_blank">按照这个步骤进行安装-->   https://docs.docker.com/engine/installation/</a>

## (二) 将集成了开发环境的docker镜像拉取到本地

```bash
docker pull neucrack/esp-build
```
> * 国内拉去的过程可能比较慢或者出错，请耐心尝试

## (三) 运行容器

#### 基本操作

* 使用`docker run`命令运行，配合合适的参数即可开始使用咯，可以使用`man docker-run`进行查看，最常用的几个参数如下：
 * `-v` : 挂载宿主机文件目录到容器文件目录
 * `-i` : 交互模式
 * `-t` : 使用终端进行交互
 * `--rm` : 容器结束后删除容器及其产生的相关文件
 * `--name` : 为容器取名，如果没有这个参数，docker会自动生成一个名字
 * `--device` : 挂载宿主机设备到容器中
 * `-e` : 运行容器时添加环境变量到容器中

* 退出容器：
```bash
exit
```

* 如果没有使用`--rm`参数，在退出容器后想继续进入容器
```bash
docker start 容器名(或者ID号)
docker attach 容器名(或者ID号)
```
> 若不知道旧的容器名，使用`docker ps -a` 查看

#### 针对模块具体举例:

##### 1. 运行开发esp8266的容器

使用SDK：
```bash
sudo docker run -ti --name esp8266-builder -e SDK_PATH=/build/ESP8266_RTOS_SDK/ -e BIN_PATH=/build/bin --device /dev/ttyUSB0:/dev/ttyUSB0 -v /data/esp/esp8266:/build neucrack/esp-build /bin/bash
```
> * `-name`指定运行容器的名字
> * `-e`添加环境变量（具体的环境变量由SDK决定，阅读SDK的使用说明即可，将SDK下载或者克隆到相应文件夹下，比如这里`/build/esp8266/ESP_RTOS_SDK/`）
> * `--device`将宿主机的`/dev/ttyUSB0`设备挂载到容器`/dev/ttyUSB0`(这里是USB转串口设备，具体的设备名可以使用 `ls /dev/*|grep ttyUSB` 或 `dmesg|grep ttyUSB` 或 `dmesg|grep ttyS` 查看
)
> * `-v` 将/data/esp文件夹挂载到容器的/build文件夹中，即宿主机这个文件夹和容器的build文件夹实现了同步和共享


##### 2. 运行开发esp32的容器

使用esp-idf：

将官方的库克隆到本地

```bash
cd /data/esp/esp32
git clone --recursive https://github.com/espressif/esp-idf.git
```
> * 注意文件夹路径不能有空格

> * 注意使用--recursive将子模块一同引进来
如果没有使用，可以使用如下命令进行更新
```bash
cd /data/esp/esp32/esp-idf
git submodule update --init
```

```bash
docker run -ti --name esp32-builder -e IDF_PATH=/build/esp32/esp-idf --device /dev/ttyUSB0:/dev/ttyUSB0 -v /data/esp:/build neucrack/esp-build /bin/bash
```
> * `-name`指定运行容器的名字
> * `-e`添加环境变量（设置IDF_PATH的地址为/data/esp/esp32/esp-idf,所以将）
> * `--device`将宿主机的`/dev/ttyUSB0`设备挂载到容器`/dev/ttyUSB0`(这里是USB转串口设备，具体的设备名可以使用 `ls /dev/*|grep ttyUSB` 或 `dmesg|grep ttyUSB` 或 `dmesg|grep ttyS` 查看
)
> * `-v` 将/data/esp文件夹挂载到容器的/build文件夹中，即宿主机这个文件夹和容器的build文件夹实现了同步和共享

##### 3. 运行同时可以开发多个芯片的容器

在前两者的基础上改改环境变量和文件夹映射就可以


## (四) 编写 下载 应用程序
在已经运行了并进入容器之后（*所以下面的命令都在容器中执行，不是在宿主机中哦*），根据SDK的使用说明使用

比如：

##### esp8266 RTOS SDK

开始可以使用`example/`下的例子直接测试，使用方法见具体例子下的readme，注意环境变量的要求，执行`gen_misc.sh`脚本编译程序，生成二进制文件*.bin.
然后使用下载工具下载到模块，
eg:
```bash
 esptool -cc esp8266 -cp /dev/ttyUSB0 -cd nodemcu -ca 0x00000 -cf $BIN_PATH/eagle.flash.bin -ca 0x20000 -cf $BIN_PATH/eagle.irom0text.bin
```
> * 参数使用`man esptool`进行查看。二进制文件文件名及地址参考SDK说明
> * 注意在下载的时候串口不能被占用哦～（*比如串口助手正在使用串口*）否则会下载失败滴


##### esp32 SDK

根据example/文件夹下的readme内容进行操作
* 进入具体的example目录,比如`hello-world/`目录下，然后`make menuconfig`设置参数
* 然后使用`make flash`进行编译丶链接丶烧写
> 注意在下载的时候串口不能被占用哦～（*比如串口助手正在使用串口*）否则会下载失败滴
* 下载完成之后按复位键(<kbd>EN</kbd>脚失能后使能)即可运行
* 在宿主机或者容器内打开串口助手查看(容器内默认没有安装串口助手哦)，有输出信息。串口助手可以使用minicom,也可以在宿主机上使用带GUI的软件

  > **minicom安装使用**
  
  > 安装
  > ```bash
sudo apt-get install minicom
  > ```
  > 设置（*设置好了记得保存设置*）
  > ```bash
sudo minicom -s
  > ```
  > 运行
  > ```bash
sudo minicom
  > ```


# 二：使用eclipse

待续。。。


