#!/bin/bash

systemctl start clamd.service 
 

clamscan -r /home --move=/virus

systemctl stop clamd.service 


sh /root/CentOS8_AAI/restart.sh