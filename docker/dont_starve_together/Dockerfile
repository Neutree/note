FROM ubuntu:20.04

MAINTAINER Neucrack CZD666666@gmail.com

ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8


RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386 \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq tzdata curl \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq libstdc++6:i386 libgcc1:i386 libcurl4-gnutls-dev:i386 libcurl4-gnutls-dev \
    && DEBIAN_FRONTEND=noninteractive apt-get purge -yq \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -yq --purge \
    && DEBIAN_FRONTEND=noninteractive apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY run_dedicated_servers.sh /root/run_dedicated_servers.sh

RUN mkdir -p /root/steamcmd/ \
    && cd /root/steamcmd/ \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - \
    && chmod u+x /root/run_dedicated_servers.sh

CMD /root/run_dedicated_servers.sh

