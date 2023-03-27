#!/bin/bash

set -e

GFWLIST="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"


echo "Download gfwlist.txt from $GFWLIST"

wget -O gfwlist.txt $GFWLIST

echo "-- generate port 1080 pac file ..."
genpac --pac-proxy="SOCKS5 127.0.0.1:1080" -o autoproxy_socks5_1080.pac --gfwlist-url - --gfwlist-local gfwlist.txt --user-rule-from user_rules.txt 
echo "-----------------------------------"
echo "-- generate port 1080 pac file ..."
genpac --pac-proxy="SOCKS5 127.0.0.1:1088" -o autoproxy_socks5_1088.pac --gfwlist-url - --gfwlist-local gfwlist.txt --user-rule-from user_rules.txt 
