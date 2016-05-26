sleep 15                                                                                          
ps -ef | grep crontab | grep -v grep | cut -c 9-15 | xargs kill -s 9                                 
exit