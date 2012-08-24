#!/bin/bash

###### USER EDITABLE FIELD BELOW ######
appfolder=$(pwd)
###### USER EDITABLE FIELD ABOVE ######
echo $appfolder

sopchannel () {
	###### USER EDITABLE FIELD BELOW ######
	clear
	echo "Enter the number of the channel you would like or manually type out the complete url"	
	echo
	echo "1. sop://broker.sopcast.com:3912/132927 Bloodzeed[HQ] [EN]"
	echo "2. sop://broker.sopcast.com:3912/133336 Angus Og [EN]"
	echo "3. sop://broker.sopcast.com:3912/6816 Yes [EN]"
	echo "4. sop://broker.sopcast.com:3912/132431 Tzonner1"
	echo "5. sop://broker.sopcast.com:3912/123456 TBD Sopcast"
	echo "6. sop://broker.sopcast.com:3912/131822 Footy Goal2"
	echo "7. sop://broker.sopcast.com:3912/132348 LiveSportszone [RO]"
	echo "8. sop://221.12.89.140:3912/18669 Test Channel"
	echo 
	###### USER EDITABLE FIELDS ABOVE ######
	read choice
	case $choice in
			1) channelname="sop://broker.sopcast.com:3912/132927";;
			2) channelname="sop://broker.sopcast.com:3912/133336" ;;
			3) channelname="sop://broker.sopcast.com:3912/6816" ;;
			4) channelname="sop://broker.sopcast.com:3912/132431" ;;
			5) channelname="sop://broker.sopcast.com:3912/123456" ;;
			6) channelname="sop://broker.sopcast.com:3912/131822" ;;
			7) channelname="sop://broker.sopcast.com:3912/132348" ;;
			8) channelname="sop://221.12.89.140:3912/18669" ;;
			*) channelname=$choice ;;
		esac
	if [ -z "$channelname" ]; then echo "Value not set, so exiting"; return 1; fi
	clear
	echo "Function found channel name $channelname"
	echo
}

randomport () {
	FLOOR=6000
	ranport=0
	portfound="no"
	while [ $portfound != "yes" ]; do
		while [ "$ranport" -le $FLOOR ]; do
		 	ranport=$RANDOM
		done
		grep "$ranport$" $appfolder/*.conf
		grepfind=$?
		case $grepfind in
			0) ranport=0 ;;
			1) portfound="yes" ;;
			2) portfound="yes" ;;
			*) ranport=0 ;;
		esac
	done
	echo "Random $ranport"
}

cronstart () {
	jobname=$1
	echo "Is the recording start date today? (y)/n"
	echo
	read choice
	if [ "$choice" == "n" ]; then
		clear
		echo "Enter the day of month for the recording."
		echo "-DO NOT add a leading zero"
		echo "-Default is today: `date +%-d`."
		echo
		read crondate
		if [ -z "$crondate" ]; then crondate=$(date +%-d); fi

		clear
		echo "Enter the number of month for the recording."
		echo "-DO NOT add a leading zero"
		echo "-Default is today: `date +%-m`."
		echo
		read cronmonth
		if [ -z "$cronmonth" ]; then cronmonth=$(date +%-m); fi
	
		clear
		echo "Enter the number of day of the week for the recording."
		echo "-DO NOT add a leading zero"
		echo "-Sunday=0 Monday=1 Tuesday=2 Wednesday= 3 "
		echo "-Thursday=4 Friday=5 Saturday=6"
		echo "-Default is today: `date +%-w`."
		echo
		read cronday
		if [ -z "$cronday" ]; then cronday=$(date +%-w); fi
	else
		crondate=$(date +%-d)
		cronmonth=$(date +%-m)
		cronday=$(date +%-w)
	fi
	clear
	echo "Enter hour of day for recording."
	echo "-DO NOT add a leading zero"
	echo "-24 hour time"
	echo "-Recommend starting recording earlier than actual start time"
	echo "-Default is this hour: `date +%-H`."
	echo
	read cronhour
	if [ -z "$cronhour" ]; then cronhour=$(date +%-H); fi
	
	clear
	echo "Enter minute of hour for recording."
	echo "-DO NOT add a leading zero"
	echo "-Recommend starting recording earlier than actual start time"
	echo "-Default is this minute: `date +%-M`."
	echo
	read cronminute
	if [ -z "$cronminute" ]; then cronminute=$(date +%-M); fi
	
	clear
	cron="$cronminute $cronhour $crondate $cronmonth $cronday cd $appfolder && $appfolder/ssh-sopdvr.sh $jobname start >> $jobname.log"
	echo "The following will be written to your crontab file. Press enter to continue press Ctrl+C to quit"
	echo "$jobname will start recording the $crondate day of the $cronmonth month at $cronhour:$cronminute."	
	echo
	echo "$cron"
	echo
	read
	
	echo "Writing to  crontab file"
	tmpfile="/tmp/cron.tmp"
	crontab -l > $tmpfile
	echo $cron >> $tmpfile
	crontab $tmpfile
	rm $tmpfile
}

cronend () {
	jobname=$1
	crondate=$2
	cronmonth=$3
	cronday=$4
	cronhour=$5
	cronminute=$6
	clear
	echo "Is the ending of recording date today? (y)/n"
	echo
	read choice
	if [ "$choice" == "n" ]; then
		clear
		echo "Enter the day of month for the ending of recording."
		echo "-DO NOT add a leading zero"
		echo "-Default is cron start date: $crondate."
		echo
		read crondateend
		if [ -z "$crondateend" ]; then crondateend=$crondate; fi

		clear
		echo "Enter the number of month for the ending of recording."
		echo "-DO NOT add a leading zero"
		echo "-Default is cron start day: $cronmonth."
		echo
		read cronmonthend
		if [ -z "$cronmonthend" ]; then cronmonthend=$cronmonthe; fi
	
		clear
		echo "Enter the number of day of the week for the ending of recording."
		echo "-DO NOT add a leading zero"
		echo "-Sunday=0 Monday=1 Tuesday=2 Wednesday= 3 "
		echo "-Thursday=4 Friday=5 Saturday=6"
		echo "-Default cron start day of the week: $cronday."
		echo
		read crondayend
		if [ -z "$crondayend" ]; then crondayend=$cronday; fi
	else
		crondateend=$crondate
		cronmonthend=$cronmonth
		crondayend=$cronday
	fi
	clear
	echo "Enter hour of day for ending of recording ."
	echo "-DO NOT add a leading zero"
	echo "-24 hour time"
	echo "-Recommend ending recording later than actual end time"
	echo "-Default is cron start hour: $cronhour."
	echo
	read cronhouredn
	if [ -z "$cronhourend" ]; then cronhourend=$cronhour; fi
	
	clear
	echo "Enter minute of hour for ending of recording."
	echo "-DO NOT add a leading zero"
	echo "-Recommend ending recording later than actual end time"
	echo "-Default is cron start minute: $cronminute."
	echo
	read cronminuteend
	if [ -z "$cronminuteend" ]; then cronminuteend=$cronminute; fi
	
	clear
	cronendt="$cronminuteend $cronhourend $crondateend $cronmonthend $crondayend cd $appfolder && $appfolder/sopdvr.sh $jobname kill >> $jobname.log"
	echo "The following will be written to your crontab file. Press enter to continue press Ctrl+C to quit"
	echo "$jobname will stop recording the $crondateend day of the $cronmonthend month at $cronhourend:$cronminuteend"
	echo
	echo "$cronendt"
	echo
	read
	clear
	echo "Writing to  crontab file"
	tmpfile="/tmp/cron.tmp"
	crontab -l > $tmpfile
	echo $cronendt >> $tmpfile
	crontab $tmpfile
	rm $tmpfile
}

####JOB CREATION
creation () {
	clear
	echo "Create new recording."
	echo "Enter the job/save name."
	echo
	echo "No Spaces"
	echo
	read jobname
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	echo $jobname > "$appfolder/$jobname.conf"
	clear
	echo "Enter the folder you would like to save the recording to:"
	echo "default is present directory: `pwd`"
	echo 
	read foldername
	if [ -z "$foldername" ]; then foldername=$(pwd); fi
	echo $foldername/$jobname >> "$appfolder/$jobname.conf"
	clear
	randomport
	jobportin=$ranport
	randomport
	jobportout=$ranport
	echo "Random ports generated"
	echo
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname >> "$appfolder/$jobname.conf"
	echo $jobportin >> "$appfolder/$jobname.conf"
	echo $jobportout >> "$appfolder/$jobname.conf"
	#Get crontab info
	echo
	cronstart $jobname
	if [ $? == 1 ]; then echo "Cron start failed"; return; fi
	cronend $jobname $crondate $cronmonth $cronday $cronhour $cronminute
	if [ $? == 1 ]; then echo "Cron end failed"; return; fi
	echo
	echo "Job creation completed. Press enter to return to menu."
	read	
}

instantcreate () {
	clear
	echo "Create new recording."
	echo "Enter the job/save name."
	echo
	echo "No Spaces"
	echo
	read jobname
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	echo $jobname > "$appfolder/$jobname.conf"
	clear
	echo "Enter the folder you would like to save the recording to:"
	echo "default is present directory: `pwd`"
	echo 
	read foldername
	if [ -z "$foldername" ]; then foldername=$(pwd); fi
	echo $foldername/$jobname >> "$appfolder/$jobname.conf"
	clear
	randomport
	jobportin=$ranport
	randomport
	jobportout=$ranport
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname >> "$appfolder/$jobname.conf"
	echo $jobportin >> "$appfolder/$jobname.conf"
	echo $jobportout >> "$appfolder/$jobname.conf"
	clear
	echo "Do you want to set a record end time? If you do not you will have to manually kill VLC and SP-SC by running killall sp-ec and killall vlc"
	echo
	echo "y/(n)"
	echo
	read choice
	if [ "$choice" == "y" ]; then
		crondate=$(date +%-d)
		cronday=$(date +%-w)
		cronmonth=$(date +%-m)
		cronhour=$(date +%-H)
		cronminute=$(date +%-M)
		cronend $jobname $crondate $cronmonth $cronday $cronhour $cronminute
		if [ $? == 1 ]; then echo "Cron end failed"; return; fi
	fi
	clear
	recordnow $jobname	
}

recordnow () {
	clear
	echo "Recoring will begin now of $1"
	echo 
	jobname=$1
	if [ "$2" = "kill" ]; then
		echo "$appfolder/$jobname.conf"
		jobfile=$(<"$appfolder/$jobname.conf")
		set -- $jobfile
		jobportin=$4
		jobportout=$5
		jobchannel=$3
		killjob $jobname $jobchannel $jobportin $jobportout
	else	
		echo "$appfolder/$jobname.conf"
		jobfile=$(<"$appfolder/$jobname.conf")
		set -- $jobfile
		jobportin=$4
		jobportout=$5
		jobchannel=$3
		jobfile=$2
		echo "recording channel $jobchannel $jobportin $jobportout for job $jobname saving to $jobfile.asf"
		####FROM AUTOSOP.SH
		killallreplace $jobchannel $jobportin $jobportout
		sopconnect $jobchannel $jobportin $jobportout
		echo "Attemting to record $jobchannel"
		echo 'VLC Starting'
		nohup cvlc "http://127.0.0.1:$jobportout/tv.asf" :demux=dump :demuxdump-file="$jobfile".asf &
		echo 'done'

		sleep 15

		checkstatus $jobname $jobchannel $jobfile $jobportin $jobportout
	fi
}

checkstatus () {
	###Check for file creation
	jobname=$1
	jobchannel=$2
	jobfile=$3
	jobportin=$4
	jobportout=$5
	check=1
	x=1
	newfile="1"
	retry=0	
	fail="false"
	filesize=0
	###### USER EDITABLE FIELD BELOW ######
	###### Max times to check if stream is recording checks every 30 seconds 500 = over 4 hours.
	###### Max retries toconnect stream each interval is about 1 minute.
	maxtime=500
	maxretry=20
	###### USER EDITABLE FIELD BELOW ######
	clear
	echo "Connection started: Checking connections."
	while [ $check -le "$maxtime" ]; do
		ps ax | grep -v grep | grep "sp-sc.$jobchannel.$jobportin.$jobportout$"
		if [ $? == "0" ]; then
			echo "Sopcast stream is still running. :)"
			ps ax | grep -v grep | grep "http://127.0.0.1:$jobportout/tv.asf :demux=dump"
			if [ $? == "0" ]; then
				echo "VLC Recording is still running. :)"
				echo "Checking size of $jobfile.asf"
				#File check is the size of the file currently filesize is previous.
				filecheck=$(stat -c%s "$jobfile.asf")
				echo "$filecheck is newfile size previous size is $filesize"
				if [ "$filecheck" != "$filesize" ]; then
					echo "File size is increasing :)"
					filesize=$filecheck
					check=$((check+1))
					fail="false"
				else
					fail="true"
					echo "Failed Size not increasing streaming not recording :("							
				fi
			else
				fail="true"
				echo "Failed vlc not running :("				
			fi
		else
			fail="true"
			echo "Failed sp-sc not running :("
		fi
		if [ $fail = "true" ]; then
			retry=$((retry+1))
			if [ $retry == "21" ]; then
				exit
			else
				echo STREAM FAILED
				killallreplace $jobchannel $jobportin $jobportout
				#### Reconnect
				echo "Reconnecting to sopcast..."
				sopconnect $jobchannel $jobportin $jobportout
				echo "Restarting vlc player..."
				sleep 3				
				nohup cvlc "http://127.0.0.1:$jobportout/tv.asf" :demux=dump :demuxdump-file="$jobfile$newfile".asf &
				echo "New file created $jobfile$newfile"
				newfile=$((nefile+1))
				filesize="0"
			fi		
		fi
		
		#####TIME TO WAIT BETWEEN CHECKS
		for x in {30..1..3}
		do
			echo "Next check in $x"
			sleep 3
		done		
	done
}

sopconnect () {
	echo "Starting sop connect"
	## no random ports
	## nohup sp-sc $1 8901 8902 > "$appfolder/sop.log" &
	nohup sp-sc $1 $2 $3 > "$appfolder/sop.log" &
	echo "Waiting for connection to $1"
	sleep 3
	sopstarted="no"
	timeout=1
	while [ $sopstarted != "yes" ]; do
		grep "I START " "$appfolder/sop.log"
		if [ $? == "1" ]; then
			clear
			echo "Sopcast not started ($timeout/30s timeout)"
			sleep 1
			timeout=$((timeout+1))
			if [ "$timeout" == "32" ]; then
				echo "Connection timed out 30s" &
				psid=$(ps ax | grep -v grep | grep "sp-sc.$1.$2.$3"| awk '{print$1}')
				echo "Process ID of sp-sc job = $psid will be killed"
				kill -9 $psid
				nohup sp-sc $1 $2 $3 > "$appfolder/sop.log" &
				timeout=1
			fi
		else
			echo "Sopcast connected"
			sopstarted="yes"
		fi
	done
	sleep 3
}

recordonly () {
	echo Create new recording
	echo "currently broken"
	return 1
	jobname=$(zenity --entry --text="Save file name. \n\nNO SPACES")
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	if [ -z "$foldername" ]; then echo "Folder name read failed"; return; fi
	## Random	
	randomport
	jobportout=$ranport
	nohup cvlc "http://127.0.0.1:$jobportout/tv.asf" :demux=dump :demuxdump-file="$foldername/$jobname".asf &
	randomport
	jobportin=$ranport
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname
	echo $channelname >> "$appfolder/$jobname.conf"
	echo $jobportin >> "$appfolder/$jobname.conf"
	echo $jobportout >> "$appfolder/$jobname.conf"
	jobfile="$foldername/$jobname"
	checkstatus $jobname $channelname $jobfile $jobportin $jobportout
}

killallreplace () {
	##replaces killall vlc && killall sp-sc
	#psid=$(ps ax | grep -v grep | grep "sopdvr.sh $jobname start"| awk '{print$1}')
	jobchannel=$1
	jobportin=$2
	jobportout=$3
	psid=$(ps ax | grep -v grep | grep "sp-sc.$jobchannel.$jobportin.$jobportout"| awk '{print$1}')
	echo "Process ID of sp-sc job = $psid will be killed"
	kill -9 $psid
	psid=$(ps ax | grep -v grep | grep "http://127.0.0.1:$jobportout/tv.asf :demux=dump"| awk '{print$1}')
	echo "Process ID of vlc job = $psid will be killed"
	kill -9 $psid
}

killjob () {
	jobname=$1
	jobchannel=$2
	jobportin=$3
	jobportout=$4
	echo "KILL KILL KILL $jobname job"
	#kill still recording sh session.
	psid="start"
	while [ "$psid" != "end" ]; do
		psid=$(ps ax | grep -v grep | grep "sopdvr.sh $jobname start"| awk '{print$1}')
		if [ -z "$psid" ]; then psid="end"; fi
		echo "Process ID = $psid"
		kill -9 $psid
	done
	echo "Script Killed"
	killallreplace $jobchannel $jobportin $jobportout
	tmpfile=/tmp/cron.tmp
	tmpfilenew=/tmp/cronnew.tmp
	crontab -l > $tmpfile
	grep -v "sopdvr.sh"."$jobname " $tmpfile  > $tmpfilenew
	#cat $tmpfilenew > $tmpfile
	#grep -v "sopdvr.sh"."$jobname kill " $tmpfile  > $tmpfilenew
	crontab $tmpfilenew
	rm $tmpfile
	rm $tmpfilenew
	rm $appfolder/sop.log $appfolder/$jobname.conf
}

stoprec () {
	clear
	echo "Enter job name if know else leave blank."
	echo
	read jobname
	if [ "$jobname" != "" ]; then
		echo "$appfolder/$jobname.conf"
		jobfile=$(<"$appfolder/$jobname.conf")
		set -- $jobfile
		jobportin=$4
		jobportout=$5
		jobchannel=$3
		jobfile=$2
		killjob $jobname $jobchannel $jobportin $jobportout
		rm $appfolder/sop.log $appfolder/$jobname.conf
	else
		echo "Do you also want to clear crontab of all jobs? y/(n)"
		echo
		read choice
		if [ "$choice" == "y" ]; then
			cleancron
		else
			echo "Stopping VLC Recording" && killall vlc
			echo "Stopping CVLC" && killall cvlc
			echo "Stopping Sopcast Connection" && killall sp-sc
		fi
	fi
}

cleancron () {
	echo "KILL KILL KILL"
		#kill still recording sh session.
		psid="start"
		while [ "$psid" != "end" ]; do
			psid=$(ps ax | grep -v grep | grep "sopdvr.sh * start"| awk '{print$1}')
			if [ -z "$psid" ]; then psid="end"; fi
			echo "Process ID = $psid"
			kill -9 $psid
		done
		echo "Script Killed"
		psid="start"
		while [ "$psid" != "end" ]; do
			psid=$(ps ax | grep -v grep | grep "sopdvr.sh * kill"| awk '{print$1}')
			if [ -z "$psid" ]; then psid="end"; fi			
			echo "Process ID = $psid"
			kill -9 $psid
		done
		echo "Script Killed"
		echo "Stopping VLC Recording" && killall vlc
		echo "Stopping CVLC" && killall cvlc
		echo "Stopping Sopcast Connection" && killall sp-sc
		tmpfile=/tmp/cron.tmp
		tmpfilenew=/tmp/cronnew.tmp
		crontab -l > $tmpfile
		grep -v "sopdvr.sh" $tmpfile  > $tmpfilenew
		crontab $tmpfilenew
		rm $tmpfile
		rm $tmpfilenew
		rm $appfolder/*.log $appfolder/*.conf 
}

advancemenu () {
	quitadv="no"
	clear
	while [ "$quitadv" != "yes" ]; do	
		clear
		echo "1 Clean Crontab"
		echo "2 Clean nohup file"
		echo "4 test"
		echo "5 Back"
		read -n 1 choice
		case $choice in
			1) clear; cleancron ;;
			2) clear; rm nohup.out ;;
			3) clear; sopguiinstall ;;
			4) echo "TEST"; sleep 5 ;;
			5) clear; quitadv="yes" ;;
			"") clear; echo "Quitting" ; quitadv="yes" ;;
			*) clear; echo "\"$choice\" is not valid"
			sleep 1 ;;
		esac
	done
}


softwarecheck () {
	choice=""
	echo "Checking for sp-sc"
	echo
	swcheck=$(sp-sc --version)
	echo
	if [ -z "$swcheck" ]; then
		echo "Sopcast not installed correctly:"
		echo "sp-sc command not found"
		echo "Do you want to skip this check?"
		echo "Choose no for an option to install software."
		echo
		echo "(y)/n"
		echo
		read choice
		clear
		if [ "$choice" == "n" ]; then
			echo "Do you want to install missing software now? y/(n)"
			echo
			read choice
			if [ $choice == "y" ]; then
				echo "Install"
				echo "Downloading sopcast sp-sc-auth / sp-sc"
				rm sp-auth.tgz*
				wget "http://download.easetuner.com/download/sp-auth.tgz"
				if [ $? == "0" ]; then
					echo "Download of sp-sc completed"
				else
					echo "ERROR: Download of sp-sc FAILED"
					rm sp-auth.tgz*
					return 1
				fi
				
				echo "Downloading libstdcpp5"
				rm libstdcpp5.tgz*
				wget "http://www.sopcast.com/download/libstdcpp5.tgz"
				if [ $? == "0" ]; then
					echo "Download of libstdcpp5.tgz completed"
				else
					echo "ERROR: Download of libstdcpp5.tgz FAILED"
					rm libstdcpp5.tgz*
					return 1
				fi
				echo "Extracting"
				sleep 2
				tar xfzv "sp-auth.tgz"
				if [ $? == "0" ]; then
					echo "Extraction of sp-auth.tgz completed"
				else
					echo "ERROR: Extraction of sp-auth.tgz FAILED"
					rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth
					return 1
				fi
				tar xfzv "libstdcpp5.tgz"
				if [ $? == "0" ]; then
					echo "Extraction of libstdcpp5.tgz completed"
				else
					echo "ERROR: Extraction of libstdcpp5.tgz FAILED"
					rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth
					return 1
				fi
				echo "Sudo command: sudo cp -a usr/lib/libstdc++.so.5* /usr/lib"
				echo "Sudo command 2: sudo cp -a sp-auth/sp-sc-auth /usr/bin/sp-sc"
				sudo cp -a usr/lib/libstdc++.so.5* /usr/lib
				if [ $? == "0" ]; then
					echo "Copying of libstdcpp5.tgz completed"
				else
					echo "ERROR: Copying of libstdcpp5.tgz FAILED"
					rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth
					return 1
				fi
				sudo cp -a sp-auth/sp-sc-auth /usr/bin/sp-sc
				if [ $? == "0" ]; then
					echo "Copying of sp-auth/sp-sc-auth /usr/bin/sp-sc completed"
				else
					echo "ERROR: Copying of sp-auth/sp-sc-auth /usr/bin/sp-sc FAILED"
					rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth
					return 1
				fi
				echo "installed"
				rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth							
			else
				return 1
			fi
		fi
	else
		echo "sp-sc installed"
	fi

	echo "Checking for vlc"
	swcheck=$(vlc --version)	
	if [ -z "$swcheck" ]; then
		echo "VLC not installed correctly:"
		echo "vlc command not found"
		echo "Do you want to skip this check?"
		echo "Choose no for an option to install software."
		echo
		echo "(y)/n"
		echo
		read choice
		clear
		if [ "$choice" == "n" ]; then	
			echo "Do you want to install missing software now? y/(n)"
			echo
			read choice
			if [ $choice == "y" ]; then
				echo "Install"
				echo "Command to be run sudo apt-get install vlc cvlc"
				sudo apt-get install vlc cvlc
			else
				return 1
			fi
		fi
	else
		echo "vlc installed"
	fi

	echo "Checking for cvlc"
	swcheck=$(cvlc --version)
	if [ -z "$swcheck" ]; then
		echo "Commandline VLC not installed correctly:"
		echo "cvlc command not found"
		echo "Do you want to skip this check?"
		echo "Choose no for an option to install software."
		echo
		echo "(y)/n"
		echo
		read choice
		clear
		if [ "$choice" == "n" ]; then	
			echo "Do you want to install missing software now? y/(n)"
			echo
			read choice
			if [ $choice == "y" ]; then
				echo "Install"
				echo "Command to be run sudo apt-get install cvlc"
				sudo apt-get install cvlc
			else
				return 1
			fi
		fi
	else
		echo "cvlc installed"
	fi	
}

###USER MENU####
if [ -z "$1" ]; then

	quit="no"
	#softwarecheck
	clear
	while [ $quit != "yes" ]; do		
		echo "1 Job Creation"
		echo "2 Instant Job"
		echo "3 Just Record Now!"
		echo "6 Stop Recording"
		echo "7 Advance" 
		echo "8 Quit"
		echo "Enter the number of the option you would like to preform"
		read -n 1 choice
		case $choice in
			1) clear; creation ;;
			2) clear; instantcreate ;;
			3) clear; recordonly ;;
			6) clear; stoprec ;;
			7) clear; advancemenu ;;
			8) clear; quit="yes" ;;
			9) clear; echo "Quitting" ; quit="yes" ;;
			a) clear; echo "$choice is not valid"; sleep 1 ;;
		esac
	done

else
	## If arguments are sent with opening file load a job or kill a job. $2 will be the kill job flag and $1 is job name. 
	recordnow $1 $2
fi
