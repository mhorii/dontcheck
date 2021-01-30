#!/bin/bash

DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="9000"

command="${1}"

function error () {
    echo "[ERR] " "${1}"
}

function check () {

    if [ -z "${PI_HOLE}" ]; then
	error "PI_HOLE is not set."
	exit -1
    fi

    if [ -z "${PASSWORD}" ]; then
	error "PASSWORD is not set."	
	exit -1
    fi

    if [ -z "${HOST}" ]; then
	HOST=${DEFAULT_HOST}
    fi

    if [ -z "${HOST}" ]; then
	error "HOST is not set."
	exit -1
    fi

    if [ -z "${PORT}" ]; then
	PORT=${DEFAULT_PORT}
    fi

    if [ -z "${PORT}" ]; then
	error "PORT is not set."
	exit -1
    fi

}

case "${command}" in
    "build")
	docker build . -t dontcheck
	;;
    "start")
	check
	
	docker run -e PORT=${PORT} -e HOST=${HOST} -e PI_HOLE=${PI_HOLE} -e PASSWORD=${PASSWORD} --mount type=bind,source="$(pwd)",target=/dontcheck --name "dontcheck" -d -p ${PORT}:${PORT} dontcheck
	;;
    "clean")
	docker stop dontcheck
	docker rm dontcheck
	docker rmi dontcheck
	;;
    "sh")
	docker exec -ti dontcheck bash
	;;
    *)
	;;
esac     
     

