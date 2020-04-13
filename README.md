AAI CentOS8 - APM AUTO INSTALL Beta V.0.3
<pre>
쉽고 빠른 설치, 운영, 업데이트까지 고려한 설계
쉬운 업데이트 지원. (공식+인기 저장소를 사용하여 yum update 만으로 업데이트 완료)
사용자 생성,삭제,백업 스크립트 사용으로 시스템 계정, 디비 계정 자동 생성 지원
Let's Encrypt - 무료 SSL 인증서 발급 및 갱신 지원
모니터링 툴 - cockpit 지원
</pre>
 

AAI GIT 설치 방법

SSH와 SFTP 는 필히 root 권한으로 접속 합니다.
아래 명령어를 사용해서 설치를 진행 합니다. 설치 화면에서 'y' 만 누르면 설치가 진행 됩니다.
<pre>
yum -y install git \
&& cd /root/ \
&& git clone https://github.com/joosung/CentOS8_AAI.git \
&& cd CentOS8_AAI \
&& sh install.sh
</pre> 


AAI 다운로드 설치 방법

1. SSH와 SFTP 는 필히 root 권한으로 접속 합니다.
2. CentOS8_AAI-master 압축 파일을 다운로드 받으시고 압축을 해제 후 CentOS8_AAI 폴더로 변경 후 자신의 서버 /root 폴더에 업로드한다.
3. Shell(터미널)에서 /root/CentOS8_AAI 폴더내의 install.sh 파일의 퍼미션을 chmod 700 install.sh 로 해당 파일의 퍼미션을 700 으로 수정한다.
4. ./install.sh 입력후 엔터를 치고 설치를 진행 하시면 됩니다.


AAI  주요 명령

1. adduser.sh
   사용자 계정 추가, VirtualHost 추가, Mysql 계정 추가, Let's Encrypt SSL 추가 를 한번에 또는 개별적으로 진행 할 수 있습니다.

2. deluser.sh
   사용자 계정 삭제, VirtualHost 삭제, Mysql 계정 삭제, Let's Encrypt SSL 삭제 를 한번에 또는 개별적으로 진행 할 수 있습니다.

3. /etc/cron.daily/backup 파일을 에디터로 열고 '패스워드' 를 찾아서 mysql root 패스워드로 교체 합니다.

4. 스푸핑 에 관련된 메일을 받고 싶을땐 /etc/sysconfig/arpwatch 파일을 열어서 아래와 같이 수정 하세요.
   OPTIonS="-u pcap -e '메일주소' -s '보내는이(Arpwatch)' -n 'ㅣ자신의IP/24'"

5. 설지 작업이 모두 끝나면 ./chkrootkit 그리고 clamscan -r /home --move=/virus 를 각각 실행해서 바이러스와 멀웨어 등이 없는지 확인 합니다. 
   테스트 용 바이러스 파일이 생성되므로 있다면 삭제 해 줍니다.

6. cockpit 지원으로 인하여 port 9090 를 서버 방화벽에서 열어 주셔야 합니다.


그외 소소한(?) 튜닝이나 설정은 구글 검색을 또는 아파치존 QnA 를 통하여 질문 하시면서 자신이 사용하기 좋은 환경을 만들어 가시면 됩니다.

AAI 설치 및 계정 생성과 삭제 방법을 아파치존에서 동영상으로 안내 드리며, 궁금한점 또는 문의사항은 아파치존 QnA를 이용해 주시기 바랍니다.

https://apachezone.com

 
<pre>
APM 및 설치 버전은 아래와 같습니다.

httpd 2.4.x
php 7.2.x
mariadb 10.4.x
ionCube PHP Loader
Zend OPcache
Let's Encrypt
phpMyAdmin
chkrootkit
arpwatch
fail2ban
mod_evasive
mod_security
mod_security_crs
mod_expires
GeoIP
cockpit
사용지 계정 백업 스크립트 1.0.1
사용자 계정 생성 스크립트 1.0.1
사용자 계정 삭제 스크립트 1.0.1 등...... 그외 필요한 라이브러리도 같이 설치가 됩니다. 
</pre>
 

**해당 버전은 해당 APM 및 라이브러리 업데이트에 따라 달라 질 수 있습니다.