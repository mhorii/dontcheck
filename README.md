# Dontcheck

Dontcheck is a script for making you stop to check services like Twitter and Youtube, achiving it with Pi-Hole.

Pi-Hole provides functionalities to determine wether some domains can be resolved or not. Dontcheck requests Pi-Hole for adding or deleting domains that you don't check. Also, Dontcheck provides crontab-ui so that you can make config for cron without access to console.

# Setup

You need to set up Pi-Hole beforehand. See https://pi-hole.net/.

When staring Dontcheck, you can/need to set some values:
* (MUST) PI_HOLE
  - Host running Pi-Hole
  - Example: `192.168.0.2:8080`
* (MUST) PASSWORD
  - Password to login Pi-Hole
  - Example: `YOURPASSWORD`
* (OPTION) HOST
  - Host running crontab-ui
  - Example: `192.168.0.1`
  - Default: `0.0.0.0`
* (OPTION) PORT
  - Port number providing access to crontab-ui
  - Example: `8080`
  - Default: `9000`


`service.sh` is a script for that. See it for more detail. You need to build an image for Dontcheck and start a container with the image.
```
$ ./service.sh build
$ PI_HOLE=192.168.0.2:8080 PASSWORD=YOURPASSWORD ./service.sh start
```

Visit the crontab-ui to confirm that the container is running.

# Commands

`dck` is a script to control Pi-Hole with sub commands below:
* login
  - Login and get cookie as a file "cookie.txt"
  - You need to login before requesting add/delete domains
  - Example: `$ dck login`
* logout
  - Logout and remove "cookie.txt"
  - Example: `$ dck logout`
* add <domain>
  - Add domain that you don't want to check
  - Example: `$ dck add twitter.com`
* delete <domain>
  - Delete domain from the blacklist
  - Example: `$ dck delete twitter.com`

You can run `dck` via console but it is sometimes pain. I recommend that you make configuration of crontab via crontab-ui. Note that `dck` need "cookie.txt" for adding/deleting domains. So the command in crontab should be `dck login && dck add twitter.com && dck logout`.


