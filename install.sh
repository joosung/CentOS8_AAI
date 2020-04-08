#!/usr/bin/env bash

#####################################################################################
#                                                                                   #
# * APMinstaller Beta v.0.3 with CentOS8                                            #
# * CentOS-8-x86_64-1911                                                            #
# * Apache 2.4.X , MariaDB 10.4.X, PHP 7.2.X setup shell script                     #
# * Created Date    : 2020/04/07                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

echo "
 =======================================================

               < CentOS8_AAI 설치 하기>

 =======================================================
"
echo "설치 하시겠습니까? 'Y' or 'N'"
read YN
YN=`echo $YN | tr "a-z" "A-Z"`
 
if [ "$YN" != "Y" ]
then
    echo "설치 중단."
    exit
fi

echo""
echo "설치를 시작 합니다."

cd /root/CentOS8_AAI/APM

chmod 700 APMinstaller.sh

chmod 700 /root/CentOS8_AAI/adduser.sh

chmod 700 /root/CentOS8_AAI/deluser.sh

chmod 700 /root/CentOS8_AAI/restart.sh

sh APMinstaller.sh

cd /root/CentOS8_AAI

echo ""
echo ""
echo "CentOS8_AAI 설치 완료!"
echo ""
echo ""
echo ""

#설치 파일 삭제
rm -rf /root/CentOS8_AAI/APM
echo ""
rm -rf /root/CentOS8_AAI/install.sh
echo ""
exit;

esac

