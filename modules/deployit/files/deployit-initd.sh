#!/bin/bash
#
# deployit          Start/Stop the deployit daemon.
#
#Date: 07-02-2012 Version 1.0
#Author: Let's just say i have someone else to thank for this script .. 
#
# processname: deployit
# config: /opt/deployit/deployit-3.6.1-server/conf/deployit.conf
# pidfile: /var/run/deployit.pid
#
# Source function library.
. /etc/init.d/functions

RUNNINGUSER="deployit"
PROG="deployit-server"
PIDFILE="/var/run/deployit.pid"
DEPLOYIT_HOME="/opt/deployit/server"

PID=$(ps -fu $RUNNINGUSER|grep $PROG |awk '{print $2}')
if [ "$PID" != "" ]
then
	echo ${PID} >$PIDFILE
fi

status -p $PIDFILE $PROG
P_STATUS=$?

case "$P_STATUS" in
		# process is running, business as usual...
0)              A_STATUS=0
		;;

		# process is not running, but pidfile exists...
1)	        rm -f $PIDFILE
		A_STATUS=1
		;;

		# process is not running, no pidfile exists...
3)		A_STATUS=3
		;;
esac

# See how we were called.
start() {
        echo -n $"Starting $PROG: "
	if [ $A_STATUS -eq 0 -o $A_STATUS -eq 2 ] 
	then 
		echo -n "$PROG already running"  
		failure "$PROG already running"  
		echo
		exit 1
	else
		su - $RUNNINGUSER -c "${DEPLOYIT_HOME}/bin/server.sh >/dev/null &"


        	PID=$(ps -fu $RUNNINGUSER|grep deployit-server |awk '{print $2}')
       	 	if [ "$PID" != "" ]
 		then
                	echo ${PID} >$PIDFILE 
                	echo -n "$PROG started"
                	success "$PROG started"
			echo
        	else				
                	echo -n "see $PROG log for more info"
                	failure "see $PROG log for more info"
			echo	
			return 1
        	fi
	fi
}

stop() {
        echo -n "Stopping $PROG: "
        if [ $A_STATUS -eq 0 -o $A_STATUS -eq 2 ] 
	then
		kill -15 $(cat $PIDFILE)
		count=30
		sleep 0.2

		while [ "$(ps -fu $RUNNINGUSER | grep $PROG |awk '{print $2}')" != "" -a $count -ne 0 ]
		do
			sleep 1
			echo -n "."
			count=$((count - 1))
		done		
		echo
		if [ $count -eq 0 ]
		then
			echo "Sending QUIT to $PROG" >&2
			kill -9 $(cat $PIDFILE)
		fi
        	rm -f $PIDFILE
        	echo -n "$PROG stopped"
        	success "$PROG stopped"
        	echo
        	return 0
	else
        	echo -n "$PROG is not running."
        	failure "$PROG is not running."
        	echo
        	return 1
        fi
}

rhstatus() {
        status -p $PIDFILE $PROG
}

restart() {
        stop
        $0 start
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        restart
        ;;
  status)
        rhstatus
        ;;
        *)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 1
esac
