#!/bin/bash
DB='openvpn'
DBADMIN='openvpn'
DBPASSWD='openvpn'

/etc/init.d/openvpn stop

sleep 30

mysql -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set active=0  WHERE mo=0 and start=1 and active=1 and zq<=1" $DB
mysql -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set active=0  WHERE mo=2 and start=1 and active=1 and zq<=1" $DB
mysql -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set zq=zq-1  WHERE mo=0 and start=1 and active=1 and zq>1" $DB
mysql -u$DBADMIN -p$DBPASSWD -e "UPDATE test  set zq=zq-1  WHERE mo=2 and start=1 and active=1 and zq>1" $DB

sleep 60

/etc/init.d/openvpn start
/etc/init.d/saslauthd restart
/etc/init.d/openvpn restart	
service mysqld restart

