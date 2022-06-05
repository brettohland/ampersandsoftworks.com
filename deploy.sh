#!/bin/sh
bundle exec jekyll build
rsync -avz --delete _site/ ${USER}@${HOST}:~/${DIR}
exit 0
