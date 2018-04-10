#!/bin/sh

country=${1:-ru}
confDir="${2:-$(pwd)}"
curl -s http://www.vpngate.net/api/iphone/ | awk -F , -vco=${country} '$7 == toupper(co) { print($1, $NF) }' | while read host conf ; do echo ${host} >&2 ; echo ${conf} | base64 -di > "${confDir}/vpngate_${host}.conf" ; done
