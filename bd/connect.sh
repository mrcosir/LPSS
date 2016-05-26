#!/bin/bash

DB='openvpn'
DBADMIN='openvpn'
DBPASSWD='openvpn'

mysql -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set zxzt=1,start=1   WHERE username='$common_name'" $DB