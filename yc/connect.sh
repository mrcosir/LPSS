#!/bin/bash

DBhost='127.0.0.1'
DBport='3306'
DB='openvpn'
DBADMIN='lpss'
DBPASSWD='lpss'

mysql -h$DBhost -P$DBport -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set zxzt=1,start=1   WHERE username='$common_name'" $DB