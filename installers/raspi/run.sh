#!/bin/bash
for (( i=1; i < "$#"; i++ )); do
	next=$((i+1))
	arg=${!i}
	nextArg=${!next}
	if [ $arg == "--address" ]; then
		export EZBADMINTON_SERVER=$nextArg
	fi
	if [ $arg == "--username" ] || [ $arg == "-u" ]; then
		export EZBADMINTON_USERNAME=$nextArg
	fi
	if [ $arg == "--password" ] || [ $arg == "-p" ]; then
		export EZBADMINTON_PASSWORD=$nextArg
	fi
done

flutter-pi --release /opt/ezbadminton-infoscreen/bin
