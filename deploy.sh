#!/bin/sh
USER=ff6600
HOST=lunenburg.dreamhost.com             
DIR=ampersandsoftworks.com

hugo && rsync -avz --delete public/ ${USER}@${HOST}:~/${DIR}

exit 0
