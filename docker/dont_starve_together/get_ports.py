#!python3


import configparser
import os
import sys

cluster_path = sys.argv[1]

if not os.path.exists(cluster_path):
    print("path {} error".format(cluster_path))
    sys.exit(1)

conf = configparser.ConfigParser()
ports = []

cluster_conf = os.path.join(cluster_path, "cluster.ini")
master_conf = os.path.join(cluster_path, "Master", "server.ini")
caves_conf = os.path.join(cluster_path, "Caves", "server.ini")

conf.read(cluster_conf, encoding="utf-8")
ports.append(int(conf["SHARD"]["master_port"]))

conf.read(master_conf, encoding="utf-8")
ports.append(int(conf["NETWORK"]["server_port"]))

conf.read(caves_conf, encoding="utf-8")
ports.append(int(conf["NETWORK"]["server_port"]))

ip_param_str = ""
for p in ports:
    ip_param_str += f" -p {p}:{p}"

print(ip_param_str)


