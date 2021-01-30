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


# Login
function login () {
    # curl -o /dev/null -w '%{http_code}\n' -X POST http://${PI_HOLE}/admin/index.php?login= -d "pw=${PASSWORD}" -s -c ${COOKIE}
    echo $COOKIE
    curl -o /dev/null -X POST http://${PI_HOLE}/admin/index.php?login= -d "pw=${PASSWORD}" -d "persistentlogin=on" -s -c ${COOKIE}
}

# Get token
function get_token () {
    res=$(mktemp)
    curl -b ${COOKIE} -X GET http://${PI_HOLE}/admin/groups-domains.php?type=black -o ${res} -s
    token=$(cat ${res} | grep -e '<div id=\"token\".*</div>' | sed -e 's/<div id=\"token\" hidden>//' -e 's/<\/div>//')
    rm ${res}
    
    echo $token    
}

# Add a domain in blacklist
function add () {
    domain="${1}"
    
    curl  -b ${COOKIE} -X POST http://${PI_HOLE}/admin/scripts/pi-hole/php/groups.php -d "action=add_domain" -d "domain=${domain}" -d "type=1" -d "comment=" -d "token=${token}"
}

# Delete a domain from the blacklist
function delete () {
    id="${1}"
    curl -b ${COOKIE} -X POST http://${PI_HOLE}/admin/scripts/pi-hole/php/groups.php -d "action=delete_domain" -d "id=${id}" -d "token=${token}" -s
}

# Get blacklist
function list () {
    curl -b ${COOKIE} -X POST http://${PI_HOLE}/admin/scripts/pi-hole/php/groups.php -d "action=get_domains" -d "showtype=black" -d "token=${token}"
    # curl -b ${COOKIE} -X POST http://${PI_HOLE}/admin/scripts/pi-hole/php/groups.php -d "action=get_domains" -d "showtype=black" -d "token=${token}" -s
    
}

# logout
function logout () {
    curl -b ${COOKIE} -X GET http://${PI_HOLE}/admin/index.php?logout= -s
}

# Clean
function clean () {
    rm ${COOKIE}
}

function lookup () {
    domain="${1}"
    ret=$(list)
    # echo $ret
    
    # echo "${ret}" | jq . | grep -B 3 -e "${domain}" | grep -e "id" | sed -e 's/ //g' -e 's/\"id\"://g' -e 's/,//'



    # echo "${ret}" | jq '.data[] | {id: .id, domain: .domain}'  #| grep -e "id" | sed -e 's/ //g' -e 's/\"id\"://g' -e 's/,//'
    # echo $ret
    echo "${ret}" | jq ".data[] | select(.domain == \"${domain}\") | .id"
}

function usage () {
    echo "..."
}


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

# COOKIE=$(mktemp)
COOKIE="./cookie.txt"
command=${1}

if [ -z "${command}" ]; then
    usage
    exit -1
fi

# login
token=$(get_token)

# echo $token

case ${command} in
    "add")
	if [ -z "${2}" ]; then
	    usage
	    exit -1
	fi 
	add "${2}"
	;;
    "delete")
	if [ -z "${2}" ]; then
	    usage
	    exit -1
	fi 
	delete "${2}"
	;;
    "list")
	list 
	;;
    "lookup")
	if [ -z "${2}" ]; then
	    usage
	    exit -1
	fi 
	lookup "${2}"
	;;
    "login")
	login
	;;
    "logout")
	logout
	;;
    "clean")
	clean
	;;
    *)
	;;
esac

