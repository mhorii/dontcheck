#!/bin/bash

####
#
# Config
#
####
DEFAULT_PASSWORD=""
DEFALUT_PI_HOLE=""


####
#
# Utilities
#
####
function log () {
    echo "[LOG]"
}

function error () {
    echo "[ERR]" "${1}"
}

function urlencode () {
    echo "${1}" | nkf -WwMQ | tr = %
}


####
#
# Main
#
####

# Set PI_HOLE
if [ -z "${PI_HOLE}" ]; then
    PI_HOLE=${DEFAULT_PI_HOLE}
fi

if [ -z "${PI_HOLE}" ]; then
    error 'You need to specify $PI_HOLE.'
    exit -1
fi

# Set PASSWORD
if [ -z "${PASSWORD}" ]; then
    PASSWORD=${DEFAULT_PASSWORD}
fi
PASSWORD=$(urlencode ${PASSWORD})
if [ -z "${PASSWORD}" ]; then
    error 'You need to specify $PASSWORD.'
    exit -1
fi


COOKIE=$(mktemp)

exit
# Login
# curl -o /dev/null -w '%{http_code}\n' -X POST http://${PI_HOLE}/admin/index.php?login= -d "pw=${PASSWORD}" -s -c ${COOKIE}
curl -o /dev/null -X POST http://${PI_HOLE}/admin/index.php?login= -d "pw=${PASSWORD}" -s -c ${COOKIE}

# Get token
res=$(mktemp)
curl -b ${COOKIE} -X GET http://${PI_HOLE}/admin/groups-domains.php?type=black -o ${res} -s
token=$(cat ${res} | grep -e '<div id=\"token\".*</div>' | sed -e 's/<div id=\"token\" hidden>//' -e 's/<\/div>//')

# echo $token

# Add
curl  -b ${COOKIE} -X POST http://${PI_HOLE}/admin/scripts/pi-hole/php/groups.php -d "action=add_domain" -d "domain=twitter.com" -d "type=1" -d "comment=" -d "token=${token}"

# Delete
curl -b ${COOKIE} -X POST http://${PI_HOLE}/admin/scripts/pi-hole/php/groups.php -d "action=get_domains" -d "showtype=black" -d "token=${token}" -s

# Logout
curl -b ${COOKIE} -X GET http://${PI_HOLE}/admin/index.php?logout= -s

# Clean
rm ${res}
rm ${COOKIE}

