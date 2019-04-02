#!/bin/sh

set -o pipefail
country=${country:-{1:-ru}}
confDir="${2:-.}"
curl -s http://www.vpngate.net/api/iphone/ | awk -F , -vco=${country} '$7 == toupper(co) { print($1, $NF) }' | while read host conf
do
	echo ${host} >&2
	echo ${conf} | base64 -di > "${confDir}/vpngate_${host}.conf"
done
# Try to check whether remote servers actually reside in given country and eliminate those which don't
# TODO haven't thoroughly tested
which geoiplookup > /dev/null || exit
awk '$1 == "remote" { print(FILENAME, $2) }' "${confDir}"/vpngate*.conf | while read file ip ; do geoiplookup ${ip} | grep -iqwe "${country}" || rm -f ${file} ; done
