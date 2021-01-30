#!/bin/bash

command="${1}"

case "${command}" in
    "build")
	docker build . -t dontcheck
	;;
    "start")
	docker run --mount type=bind,source="$(pwd)",target=/dontcheck --name "dontcheck" -d -p 8000:8000 dontcheck
	;;
    "clean")
	docker stop dontcheck
	docker rm dontcheck
	docker rmi dontcheck
	;;
    "sh")
	docker exec -ti dontcheck sh
	;;
    *)
	;;
esac     
     

