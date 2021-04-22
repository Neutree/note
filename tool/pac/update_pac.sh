#!/bin/bash

genpac --pac-proxy="SOCKS5 127.0.0.1:1080" -o autoproxy_socks5_1080.pac --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" --user-rule-from user_rules.txt 
genpac --pac-proxy="SOCKS5 127.0.0.1:1088" -o autoproxy_socks5_1088.pac --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" --user-rule-from user_rules.txt 
