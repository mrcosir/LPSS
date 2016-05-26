#!/bin/bash

DBhost='127.0.0.1'
DBport='3306'
DB='openvpn'
DBADMIN='lpss'
DBPASSWD='lpss'

mysql -h$DBhost -P$DBport -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set zxzt=0,updata=$bytes_received,downdata=$bytes_sent,now=$bytes_received+$bytes_sent+now WHERE username='$common_name'" $DB
mysql -h$DBhost -P$DBport -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set active=0   WHERE username='$common_name' and mo>=1 and now>=quota" $DB