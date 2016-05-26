#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
cd /root
rm -f /root/LPSS.sh
echo -e "\033[33m=========================================================================\033[0m"
echo -e "\033[36m            VPN MYSQL and pam_mysql Automatic installation\033[0m"
echo ""
echo -e "\033[31m                        【一直被模仿，从未被超越】\033[0m"
echo ""
echo -e "\033[32m        请选择安装版本：\033[0m"
echo -e "\033[32m                  1.常规 VPS  -http转接-本地数据库版本\033[0m"
echo -e "\033[32m                  2.常规 VPS  -http转接-远程数据库版本\033[0m"
echo -e "\033[32m                  3.常规 VPS  -  常规  -本地数据库版本\033[0m"
echo -e "\033[32m                  4.常规 VPS  -  常规  -远程数据库版本\033[0m"
echo ""
echo -e "\033[32m                  5.网易容器  -http转接-本地数据库版本\033[0m"
echo -e "\033[32m                  6.网易容器  -http转接-远程数据库版本\033[0m"
echo -e "\033[32m                  7.网易容器  -  常规  -本地数据库版本\033[0m"
echo -e "\033[32m                  8.网易容器  -  常规  -远程数据库版本\033[0m"
echo ""
echo -e "\033[32m                                                            by 落魄书生\033[0m"
echo -e "\033[35m  >请选择安装版本：\033[0m"
echo -e "\033[33m==========================================================================\033[0m"
read no

case "$no" in
    '1' )
        wget http://tan29979.zichaob.com/CG/VPSMPB.sh && bash VPSMPB.sh;;
    '2' )
        wget http://tan29979.zichaob.com/CG/VPSMPY.sh && bash VPSMPY.sh ;;
    '3')
       wget http://tan29979.zichaob.com/CG/VPSCGB.sh && bash VPSCGB.sh ;;
    '4')
       wget http://tan29979.zichaob.com/CG/VPSCGY.sh && bash VPSCGY.sh ;;
    '5' )
        wget http://tan29979.zichaob.com/RQ/RQMPB.sh && bash RQMPB.sh ;;
    '6' )
        wget http://tan29979.zichaob.com/RQ/RQMPY.sh && bash RQMPY.sh ;;
    '7')
       wget http://tan29979.zichaob.com/RQ/RQCGB.sh && bash RQCGB.sh ;;
    '8')
       wget http://tan29979.zichaob.com/RQ/RQCGY.sh && bash RQCGY.sh ;;
    *)
        echo "输入错误"
esac

