#!/bin/bash

DBhost='127.0.0.1'
DBport='3306'
DB='openvpn'
DBADMIN='lpss'
DBPASSWD='lpss'

/etc/init.d/openvpn stop

sleep 30

mysql -h$DBhost -P$DBport -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set active=0  WHERE mo=0 and start=1 and active=1 and zq<=1" $DB
mysql -h$DBhost -P$DBport -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set active=0  WHERE mo=2 and start=1 and active=1 and zq<=1" $DB
mysql -h$DBhost -P$DBport -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set zq=zq-1  WHERE mo=0 and start=1 and active=1 and zq>1" $DB
mysql -h$DBhost -P$DBport -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set zq=zq-1  WHERE mo=2 and start=1 and active=1 and zq>1" $DB

sleep 60

/etc/init.d/openvpn start
/etc/init.d/saslauthd restart
/etc/init.d/openvpn restart	
service mysqld restart
