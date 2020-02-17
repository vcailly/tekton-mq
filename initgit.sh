#!/bin/bash
tput reset
git init
git add *
git commit -m "first commit"
git remote add origin https://github.com/vcailly/tekton-mq.git
git push -u origin master
