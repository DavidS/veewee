#!/bin/bash

sed -i -e 's/kvmhost.dasz:3142/http.debian.net/g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list

apt-get clean
