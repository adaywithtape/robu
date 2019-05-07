#!/bin/bash
#robu.sh v0.1 By TAPE
#Last edit 01-05-2019 20:00
#
#						TEH COLORZ :D
########################################################################
STD=$(echo -e "\e[0;0;0m")		#Revert fonts to standard colour/format
REDN=$(echo -e "\e[0;31m")		#Alter fonts to red normal
GRNN=$(echo -e "\e[0;32m")		#Alter fonts to green normal
BLUN=$(echo -e "\e[0;36m")		#Alter fonts to blue normal
#
#						VARIABLES
########################################################################
ALL=0
WRITE=0
COLORZ=1
VERBOSE=0
#
#						HELP
########################################################################
f_help() {
echo "Usage
./$0 -i <ip address | http://domain.com>"
echo ""
echo "Options
-a  --  show all responses
-b  --  boring colorless output
-h  --  this help
-i  --  input target IP/URL
-w  --  write/pipe friendly output
-v  --  verbose output"
exit
}
#
#						CHECK IF ROBOTS.TXT EXISTS
########################################################################
f_robcheck() {
echo $BLUN"[?]$STD Checking for robots.txt file.."
EXIST=$(curl -sI "$INPUT"/robots.txt | grep -i "HTTP/1.1 200 OK")
if [ "$EXIST" == "" ] ; then 
	echo $REDN"[-]$STD robots.txt not found"
	exit
else echo $GRNN"[+]$STD $INPUT/robots.txt $GRNN$EXIST$STD"
curl -s "$INPUT"/robots.txt | egrep -i 'allow|disallow'
echo
fi
}
#
#						STANDARD
########################################################################
f_standard() {
echo $BLUN"[?]$STD Checking for successful HTTP requests.."
for i in $(curl -s "$INPUT"/robots.txt | egrep 'Disallow:|Allow:' | sed -e 's/Disallow: //g' -e 's/Allow: //g') ; do
	if [ "$VERBOSE" == "1" ] ; then
		FULLRESULT=$(curl -sI "$INPUT""$i")
		RESULT=$(curl -sI "$INPUT""$i" | head -n1)
		if [[ "$RESULT" =~ "200 OK" ]] ; then
			echo $GRNN"[+]$STD $INPUT$GRNN$i$STD"
			echo $STD"$FULLRESULT"
		fi
	elif [ "$VERBOSE" == "0" ] ; then
		RESULT=$(curl -sI "$INPUT""$i" | head -n1)
		if [[ "$RESULT" =~ "200 OK" ]] ; then
			echo $GRNN"[+]$STD $INPUT$i"
		fi
	fi
done
}
#
#						ALL RESPONSES
########################################################################
f_all() {
echo $BLUN"[?]$STD Showing all HTTP responses"
for i in $(curl -s "$INPUT"/robots.txt | egrep 'Disallow:|Allow:' | sed -e 's/Disallow: //g' -e 's/Allow: //g') ; do
	if [ "$VERBOSE" == "1" ] ; then
		FULLRESULT=$(curl -sI "$INPUT""$i")
		RESULT=$(curl -sI "$INPUT""$i" | head -n1)
			if [[ "$RESULT" =~ "200 OK" ]] ; then
				echo $GRNN"[+]$STD $INPUT$GRNN$i$STD"
				echo $STD"$FULLRESULT"
			else echo $REDN"[-]$STD $INPUT$i"
				echo $STD"$FULLRESULT"
			fi
	elif [ "$VERBOSE" == "0" ] ; then
		RESULT=$(curl -sI "$INPUT""$i" | head -n1)
		if [[ "$RESULT" =~ "200 OK" ]] ; then
			echo $GRNN"[+]$STD $INPUT$GRNN$i$STD"
		else echo $REDN"[-]$STD $i"
		fi
	fi
done
}
#
#						OPTION FUNCTIONS
########################################################################
while getopts ":abhi:wv" opt; do
  case $opt in
	a) ALL=1 ;;
	b) COLORZ=0 ;;
	h) f_help ;;
	i) INPUT=$OPTARG ;;
	w) WRITE=1 ;;
	v) VERBOSE=1 ;;
  esac
done
#						INPUT CHECKS
########################################################################
#
if [ $# -eq 0 ] ; then 
f_help
fi
if [[ "$WRITE" == "1" && "$VERBOSE" == "1" ]] ; then
	echo $RED"[-]$STD Verbose output not possible with -w"
	f_help
	exit
fi
#						RUN SCRIPT BASED ON SWITCHES
########################################################################
#
if [ "$WRITE" == "1" ] ; then COLORZ=0 ; fi
if [ "$COLORZ" == "0" ] ; then read STD REDN GRNN BLUN <<< "" ; fi
#
if [[ "$ALL" == "1" && "$WRITE" == "0" ]] ; then
	f_robcheck
	f_all
elif [[ "$ALL" == "1" && "$WRITE" == "1" ]] ; then
	for i in $(curl -s "$INPUT"/robots.txt | egrep 'Disallow:|Allow:' | sed -e 's/Disallow: //g' -e 's/Allow: //g') ; do
	RESULT=$(curl -sI "$INPUT""$i" | head -n 1)
		echo "$INPUT""$i"
	done
elif [[ "$ALL" == "0" && "$WRITE" == "0" ]] ; then  
	f_robcheck
	f_standard
elif [[ "$ALL" == "0" && "$WRITE" == "1" ]] ; then  
	for i in $(curl -s "$INPUT"/robots.txt | egrep 'Disallow:|Allow:' | sed -e 's/Disallow: //g' -e 's/Allow: //g') ; do
		RESULT=$(curl -sI "$INPUT""$i" | head -n1)
		if [[ "$RESULT" =~ "200 OK" ]] ; then
			echo "$INPUT$i"
		fi
	done
fi
#
