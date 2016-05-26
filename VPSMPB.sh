#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
cd /root
rm -f /root/VPSMPB.sh
echo -e "\033[33m=========================================================================\033[0m"
echo -e "\033[36m             VPN MYSQL and pam_mysql Automatic installation\033[0m"
echo ""
echo -e "\033[32m                      版本：http转接 -- 本地数据库\033[0m"
echo ""
echo -e "\033[32m                                                            by 落魄书生\033[0m"
echo -e "\033[35m    请按回车继续开始安装\033[0m"
echo -e "\033[33m==========================================================================\033[0m"
echo "$CopyrightLogo";
read
cd /
echo "安装openvpn"
rpm -ivh https://github.com/mu228/LPSS/raw/master/epel-release-6-8.noarch.rpm
echo "升级"
yum -y update
yum -y install vixie-cron  
yum -y install crontabs  
echo "防火墙" 
iptables -F
service iptables save
service iptables restart 
setenforce 0
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -A INPUT -p TCP --dport 443 -j ACCEPT
iptables -A INPUT -p TCP --dport 80 -j ACCEPT
iptables -A INPUT -p TCP --dport 3306 -j ACCEPT
iptables -A INPUT -p TCP --dport 8080 -j ACCEPT 
iptables -A INPUT -p TCP --dport 22 -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
service iptables save
service iptables restart
setenforce 0

yum install -y wget squid openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig 
yum install -y openvpn 
cd /etc/openvpn/
wget https://github.com/mu228/LPSS/raw/master/EasyRSA-2.2.2.tar.gz
wget https://github.com/mu228/LPSS/raw/master/MP/server.conf
wget https://github.com/mu228/LPSS/raw/master/openvpn-auth-pam.so
wget https://github.com/mu228/LPSS/raw/master/bd/connect.sh
wget https://github.com/mu228/LPSS/raw/master/bd/disconnect.sh
wget https://github.com/mu228/LPSS/raw/master/bd/test.sh
chmod +x /etc/openvpn/connect.sh
chmod +x /etc/openvpn/disconnect.sh
chmod +x /etc/openvpn/test.sh

tar -zxvf EasyRSA-2.2.2.tar.gz

chkconfig crond on
/sbin/service crond restart
cd /etc
sleep 1
echo "40 3 * * * root  /etc/openvpn/test.sh"  >> crontab
/sbin/service crond restart
rm -f sysctl.conf
wget https://github.com/mu228/LPSS/raw/master/sysctl.conf
chmod 0755 /etc/sysctl.conf
sysctl -p

echo  "配置Squid"
cd /etc/squid
rm -f ./squid.conf
wget https://github.com/mu228/LPSS/raw/master/squid.conf
wget https://github.com/mu228/LPSS/raw/master/squid_passwd
chmod 0755 /etc/squid/squid.conf
squid –z
squid -s 

chkconfig squid on 
chkconfig openvpn on  
chkconfig squid on  

echo "安装mysql..."
yum -y install mysql-server
echo 
echo
echo
sleep 2
echo "启动Mysql服务"
service mysqld start
echo 
echo 
echo "设置Mysql开机启动"
chkconfig mysqld on
echo "正在开启3306端口"
/sbin/iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
/etc/rc.d/init.d/iptables save
echo 

sleep 1
echo "pam_mysql安装开始"
yum install -y mysql-devel pam-devel gcc gcc-c++ openssl
sleep 1
echo "pam_mysql下载解压"
wget https://github.com/mu228/LPSS/raw/master/pam_mysql-0.7RC1.tar.gz
tar zxvf pam_mysql-0.7RC1.tar.gz
echo   
sleep 1
cd pam_mysql-0.7RC1
echo "文件校验"
sleep 1
./configure –with-openssl
echo
sleep 2
./configure
echo  
sleep 1
echo  "安装中"
make
make install
ln /lib/security/pam_mysql.* /lib64/security/

cd /etc/pam.d
wget https://github.com/mu228/LPSS/raw/master/bd/openvpn
cd /home
wget  https://github.com/mu228/LPSS/raw/master/vpn.sql

cd /etc
wget https://github.com/mu228/LPSS/raw/master/MP/mproxy
chmod 0755 mproxy

echo "安装 完毕"

echo  "重启服务"
service mysqld restart
/etc/init.d/saslauthd start
service squid start

echo  "设置mysql密码"
mysql -e " 

use mysql;
update user set password=password('vpnadmin') where user='root';
flush privileges;
grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;

"
service mysqld restart

/etc/init.d/mysqld stop
sleep 1
echo -e "\r" | mysqld_safe --user=mysql --skip-grant-tables --skip-networking & 
sleep 1

mysql -uroot mysql -e "
UPDATE user SET Password=PASSWORD('vpnmysql') where USER='root';

FLUSH PRIVILEGES;

"
/etc/init.d/mysqld restart 

mysql -uroot -pvpnmysql -e "

CREATE DATABASE openvpn;

USE openvpn;

GRANT ALL ON openvpn.* TO 'openvpn'@'localhost' IDENTIFIED BY 'openvpn';

source /home/vpn.sql

INSERT INTO test(username,password,name,note,mo,quota,now,zq,zxzt,start,active,updata,downdata) VALUES('test', ENCRYPT('123456'),'test','12321',1,10240000,0,30,0,0,1,0,0);

"

rm -f /home/vpn.sql

cd /etc/openvpn/easy-rsa/
source vars
./clean-all
echo 
echo "正在生成CA证书文件..."
echo 
sleep 1
echo -e "nnnnnnnn" | ./build-ca
echo -e "nnnnnnnnnn" | ./build-key-server server && echo -e "nnnnnnnnnn" | ./build-key user01
./build-ca
echo "正在生成服务端证书，请根据提示输入 y 进行确认，按回车继续"
read
./build-key-server centos
echo 
echo "正在生成SSL加密证书，这是一个漫长的过程..."
sleep 4
./build-dh
echo
echo "正在生成TLS密钥..."
sleep 2
openvpn --genkey --secret ta.key
cp /etc/openvpn/easy-rsa/keys/ca.crt /home/

/etc/init.d/saslauthd restart
/etc/init.d/openvpn restart	
service mysqld restart
service squid start
echo "数据库结构与认证模块测试.."
testsaslauthd -u test -p 123456 -s openvpn
cd /etc
./mproxy -l 8080 -d

echo '=========================================================================='
echo 
Client='                      本地数据库版安装完毕

         常规模板地址：https://github.com/mu228/LPSS/raw/master/openvpn-http.ovpn
	  
	  mysql用户名:root  mysql密码：vpnmysql  端口：3306  数据库：openvpn

	        注：证书在home目录 【安全起见 请自行修改数据库信息】
				
==========================================================================';
echo "$Client";


