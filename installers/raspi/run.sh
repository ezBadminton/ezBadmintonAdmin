#!/bin/bash
if [ $# -ge 2 ]; then
	if [ $1 == "--address" ]; then
		export EZBADMINTON_SERVER=$2
	fi
fi

flutter-pi --release /opt/ezbadminton-infoscreen/bin
