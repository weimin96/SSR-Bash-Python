#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

rm -rf /usr/local/SSR-Bash-Python
cd /usr/local
git clone https://github.com/weimin96/SSR-Bash-Python.git
cd /usr/local/SSR-Bash-Python
git checkout master
git pull
