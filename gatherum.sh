#!/bin/bash

IP=$1
nmap $IP > tmp.txt
TEMP=$PWD/"tmp.txt"
GREEN="\e[32m"
CYAN="\e[36m"
RED="\e[31m"
BOLD="\e[1m"
ENDCOLOR="\e[0m"

function port-check() {
    cat tmp.txt | grep $1/ > /dev/null 2>&1
    if [ "$?" -eq 0 ]
    then
        #echo "$1 was found!"
        return 0
    else
        #echo "$1 was NOT found!"
        return 1
    fi
}

function nmap-exec() {
    if [ "$?" -eq 0 ]
    then
        echo -e "${GREEN}\r\n[+] $3 on Port $1 Detected!\r\n${ENDCOLOR}"
        nmap -p $1 $2 $IP
    fi
}

function port() {
    port-check $1
    if [ "$?" -eq 0 ]
    then
        nmap-exec $1 $2 $3
    else
        #echo -e "${RED}\r\n[-] $3 on Port $1 NOT Detected!${ENDCOLOR}"
        return 1
    fi
}

function clean-up() {
    rm tmp.txt
    rm openPorts.txt
}

awk '/open/ {print}' tmp.txt > openPorts.txt
cat openPorts.txt | grep "open" > /dev/null 2>&1
if [ "$?" -eq 0 ]
then
    echo -e "${BOLD}\r\nOPEN PORTS DISCOVERED:\r\n${ENDCOLOR}"
else
    echo -e "${RED}\r\n[-] NO OPEN PORTS DETECTED!${ENDCOLOR}"
    clean-up
    exit 1
fi

while read -r line
do
    echo -e "${CYAN}[+] "$line"${ENDCOLOR}" 
done < openPorts.txt
echo -e "${BOLD}\r\nBeginning Enumeration...${ENDCOLOR}"

port 21 --script=ftp-anon.nse FTP
port 22 --script=ssh2-enum-algos.nse SSH # Check/add scripts!
port 23 --script=telnet-ntlm-info.nse Telnet
port 25 --script=smtp-enum-users.nse SMTP # Check/add scripts!
port 53 --script=dns-brute.nse DNS
port 80 --script=http-enum.nse,http-wordpress-enum.nse,http-backup-finder HTTP
port 110 --script=pop3-ntlm-info.nse,pop3-capabilities.nse POP3 # Check/add scripts!
port 143 --script=imap-ntlm-info.nse,imap-capabilities.nse IMAP # Check/add scripts!
port 443 --script=http-enum.nse,http-wordpress-enum.nse,http-backup-finder HTTPS # Check/add scripts!
port 445 --script=smb-enum-shares.nse,smb-enum-users.nse SMB
port 465 --script=smtp-enum-users.nse SMTPS # Check/add scripts!
port 993 --script=imap-ntlm-info.nse,imap-capabilities.nse IMAPS # Check/add scripts!
port 995 --script=pop3-ntlm-info.nse,pop3-capabilities.nse POP3S # Check/add scripts!
port 3389 --script=rdp-enum-encryption.nse RDP # Check/add scripts!

clean-up
exit 0
