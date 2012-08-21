#!/bin/bash

###### USER EDITABLE FIELD BELOW ######
appfolder=$(pwd)
###### USER EDITABLE FIELD ABOVE ######
echo $appfolder

sopchannel () {
	###### USER EDITABLE FIELD BELOW ######
	channelname=$(zenity --list --height=300 --width=400 --editable --text="Choose channel to record from.\n\nChanges can be made to Channels." \
		--column=Channel --column=Name \
		"sop://broker.sopcast.com:3912/132927" "Bloodzeed[HQ] [EN]" \
		"sop://broker.sopcast.com:3912/133336" "Angus Og [EN]" \
		"sop://broker.sopcast.com:3912/6816" "Yes [EN]" \
		"sop://broker.sopcast.com:3912/132431" "Tzonner1" \
		"sop://broker.sopcast.com:3912/123456" "TBD Sopcast" \
		"sop://broker.sopcast.com:3912/131822" "Footy Goal2" \
		"sop://broker.sopcast.com:3912/132348" "LiveSportszone [RO]" \
		"sop://221.12.89.140:3912/18669" "Test Channel" \
	)

	###### USER EDITABLE FIELDS ABOVE ######
	if [ -z "$channelname" ]; then echo "Value not set, so exiting"; return 1; fi
	echo "Function found channel name $channelname"
}

cronstart () {
	jobname=$1
	zenity --question --text="Is the recording start date today?"
	if [ $? == "1" ]; then
		crondate=$(zenity --scale \
			--text="Enter day of month for recording." \
			--value=$(date +%-d) \
			--min-value=1 \
			--max-value=31 \
		)
		if [ -z "$crondate" ]; then echo "crondate read failed"; return; fi
		cronmonth=$(zenity --scale \
			--text="Enter month for recording." \
			--value=$(date +%-m) \
			--min-value=1 \
			--max-value=12 \
		)
		if [ -z "$cronmonth" ]; then echo "cronmonth read failed"; return; fi
		cronday=$(zenity --scale \
			--text="Enter day of week for recording.\n\nSunday = 0 --- Saturday = 6" \
			--value=$(date +%-w) \
			--min-value=0 \
			--max-value=6 \
		)
		if [ -z "$cronday" ]; then echo "cronday read failed"; return; fi
	else
		crondate=$(date +%-d)
		cronmonth=$(date +%-m)
		cronday=$(date +%-w)
	fi
	cronhour=$(zenity --scale \
		--text="Enter hour of day for recording.\n\n24 hour time\nRecommend starting recording earlier than start time" \
		--value=$(date +%-H) \
		--min-value=0 \
		--max-value=23 \
	)
	if [ -z "$cronhour" ]; then echo "cronhour read failed"; return; fi
	cronminute=$(zenity --scale \
		--text="Enter minute of hour for recording.\n\nRecommend starting recording earlier than start time" \
		--value=$(date +%-M) \
		--min-value=0 \
		--max-value=60 \
	)
	if [ -z "$cronminute" ]; then echo "cronminute read failed"; return; fi
	cron=$(zenity --entry --text="The following will be written to your crontab file.\nStart of recording schedual\nChanges can be made below"\
		--entry-text="$cronminute $cronhour $crondate $cronmonth $cronday cd $appfolder && $appfolder/sopdvr.sh $jobname start >> $jobname.log"\
	)
	if [ -z "$cron" ]; then 
		echo "cron verify failed"
		rm "$appfolder/$jobname.conf"
		return 1
	fi
	#write crontab file
	tmpfile=/tmp/cron.tmp
	crontab -l > $tmpfile
	echo $cron >> $tmpfile
	crontab $tmpfile
	rm $tmpfile
}

cronend () {
	jobname=$1
	zenity --question --text="Is the recording end date today?"
	if [ $? == "1" ]; then
		crondateend=$(zenity --scale \
			--text="Enter day of month for recording end time." \
			--value=$2 \
			--min-value=1 \
			--max-value=31 \
		)
		if [ -z "$crondateend" ]; then echo "crondateend read failed"; return; fi
		cronmonthend=$(zenity --scale \
			--text="Enter month for recording." \
			--value=$3 \
			--min-value=1 \
			--max-value=12 \
		)
		if [ -z "$cronmonthend" ]; then echo "cronmonthend read failed"; return; fi
		crondayend=$(zenity --scale \
			--text="Enter day of week for recording end time.\n\nSunday = 0 --- Saturday = 6" \
			--value=$4 \
			--min-value=0 \
			--max-value=6 \
		)
		if [ -z "$crondayend" ]; then echo "cronmonthend read failed"; return; fi
	else
		crondateend=$(date +%-d)
		cronmonthend=$(date +%-m)
		crondayend=$(date +%-w)
	fi
	cronhourend=$(zenity --scale \
		--text="Enter hour of day for recording end time.\n\n24 hour time\nRecommend ending recording later than end time" \
		--value=$5 \
		--min-value=0 \
		--max-value=23 \
	)
	if [ -z "$cronhourend" ]; then echo "cronhourend read failed"; return; fi
	cronminuteend=$(zenity --scale \
		--text="Enter minute of hour for recording end time.\n\nRecommend ending recording later than end time" \
		--value=$6 \
		--min-value=0 \
		--max-value=60 \
	)
	
	#Confirm cron file
	cronendt=$(zenity --entry --text="The following will be written to your crontab file.\nEnd of recording schedual\nChanges can be made below"\
		--entry-text="$cronminuteend $cronhourend $crondateend $cronmonthend $crondayend cd $appfolder && $appfolder/sopdvr.sh $jobname kill >> $jobname.log"\
	)
	if [ -z "$cronendt" ]; then
		echo "cronendt verify failed clearing crontab"
		killjob $jobname
		rm "$appfolder/$jobname.conf"
		return 1
	fi
	#write crontab file
	tmpfile=/tmp/cron.tmp
	crontab -l > $tmpfile
	echo $cronendt >> $tmpfile
	crontab $tmpfile
	rm $tmpfile
}


####JOB CREATION
creation () {
	echo Create new recording
	jobname=$(zenity --entry --text="Job name. \n\nNO SPACES")
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	echo $jobname > "$appfolder/$jobname.conf"
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	if [ -z "$foldername" ]; then echo "Folder name read failed"; return; fi
	echo $foldername/$jobname >> "$appfolder/$jobname.conf"
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname >> "$appfolder/$jobname.conf"
	#Get crontab info
	cronstart $jobname
	if [ $? == 1 ]; then echo "Cron start failed"; return; fi
	cronend $jobname $crondate $cronmonth $cronday $cronhour $cronminute
	if [ $? == 1 ]; then echo "Cron end failed"; return; fi
}

instantcreate () {
	echo Create new recording
	jobname=$(zenity --entry --text="Job name. \n\nNO SPACES")
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	echo $jobname > "$appfolder/$jobname.conf"
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	if [ -z "$foldername" ]; then echo "Folder name read failed"; return; fi
	echo $foldername/$jobname >> "$appfolder/$jobname.conf"
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname
	echo $channelname >> "$appfolder/$jobname.conf"
	zenity --question --text="Do you want to set a record end time?\n If you do not you will have to manually kill VLC and SP-SC\nkillall sp-ec and killall vlc"
	if [ $? == "0" ]; then
		crondate=$(date +%-d)
		cronday=$(date +%-w)
		cronmonth=$(date +%-m)
		cronhour=$(date +%-H)
		cronminute=$(date +%-M)
		cronend $jobname $crondate $cronmonth $cronday $cronhour $cronminute
		if [ $? == 1 ]; then echo "Cron end failed"; return; fi
	fi
	recordnow $jobname	
}

recordnow () {
	clear
	jobname=$1
	if [ "$2" = "kill" ]; then
		killjob $jobname
	else	
		echo "$appfolder/$jobname.conf"
		jobfile=$(<"$appfolder/$jobname.conf")
		set -- $jobfile
		jobchannel=$3
		jobfile=$2
		echo "recording channel $jobchannel for job $jobname saving to $jobfile.asf"
		####FROM AUTOSOP.SH
		echo "Stopping VLC Recording" && killall vlc
		echo "Stopping CVLC" && killall cvlc
		echo "Stopping Sopcast Connection" && killall sp-sc
		sopconnect $jobchannel
		echo "Attemting to record $jobchannel"
		echo 'VLC Starting'
		nohup cvlc http://127.0.0.1:8902/tv.asf --sout=file/asf:"$jobfile".asf &
		echo 'done'

		sleep 15

		checkstatus $jobname $jobchannel $jobfile
	fi
}

killjob () {
	jobname=$1
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
	echo "Stopping VLC Recording" && killall vlc
	echo "Stopping CVLC" && killall cvlc
	echo "Stopping Sopcast Connection" && killall sp-sc
	tmpfile=/tmp/cron.tmp
	tmpfilenew=/tmp/cronnew.tmp
	crontab -l > $tmpfile
	grep -v "sopdvr.sh"."$jobname" $tmpfile  > $tmpfilenew
	crontab $tmpfilenew
	rm $tmpfile
	rm $tmpfilenew
}

checkstatus () {
	###Check for file creation
	jobname=$1
	jobchannel=$2
	jobfile=$3
	check=1
	newfile=1
	retry=0	
	fail="false"
	filesize=0
	###### USER EDITABLE FIELD BELOW ######
	###### Max times to check if stream is recording checks every 30 seconds 500 = over 4 hours.
	###### Max retries toconnect stream each interval is about 1 minute.
	maxtime=500
	maxretry=20
	###### USER EDITABLE FIELD BELOW ######
	echo "Connection started: Checking connections."
	while [ $check -le "$maxtime" ]; do
		ps ax | grep -v grep | grep sp-sc.sop
		if [ $? == "0" ]; then
			ps ax | grep -v grep | grep vlc
			if [ $? == "0" ]; then
				echo "$jobfile.asf"
				#File check is the size of the file currently filesize is previous.
				filecheck=$(stat -c%s "$jobfile.asf")
				echo $filecheck "is newfile size"
				if [ $filecheck -gt $filesize ]; then
					filesize=$filecheck
					check=$((check+1))
					fail="false"
				else
					fail="true"
					echo "Failed Size no increasing streaming not recording"							
				fi
			else
				fail="true"
				echo "Failed vlc not running"				
			fi
		else
			fail="true"
			echo "Failed sp-sc not running"
		fi
		if [ $fail = "true" ]; then
			retry=$((retry+1))
			if [ $retry == "21" ]; then
				exit
			else
				echo STREAM FAILED
				echo "Stopping Sopcast Connection" && killall sp-sc
				echo "Stopping VLC Recording" && killall vlc
				echo "Stopping CVLC" && killall cvlc
				#### Reconnect
				echo "reconnecting to sopcast"
				sopconnect $jobchannel
				echo "restarting vlc player"
				nohup cvlc http://127.0.0.1:8902/tv.asf --sout=file/asf:"$jobfile$newfile".asf &
				newfile=$((nefile+1))
				filesize="0"
			fi		
		fi
		#####TIME TO WAIT BETWEEN CHECKS
		sleep 30
	done
}

showonly () {
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname
	echo "Connecting to sopcast"
	sopconnect $channelname
	echo "Starting VLC"
	vlc http://127.0.0.1:8902/tv.asf
	killall sp-sc && echo "Stopping sopcast Connection."
}

sopconnect () {
	echo "Starting sop connect"
	nohup sp-sc $1 8901 8902 > "$appfolder/log.txt" &
	echo "Waiting for connection to $1"
	sleep 3
	sopstarted="no"
	(while [ $sopstarted != "yes" ]; do
		grep "I START " "$appfolder/log.txt"
		if [ $? == "1" ]; then
			echo "Sopcast not started"
			sleep 1
		else
			echo "Sopcast connected"
			sopstarted="yes"
		fi
	done) | zenity --progress --pulsate --text="Connecting to Sopcast channel: \n$1" --auto-close --no-cancel
	sleep 3
}

recordonly () {
	echo Create new recording
	jobname=$(zenity --entry --text="Save file name. \n\nNO SPACES")
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	if [ -z "$foldername" ]; then echo "Folder name read failed"; return; fi
	nohup cvlc http://127.0.0.1:8902/tv.asf --sout=file/asf:"$foldername/$jobname".asf &
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname
	jobfile="$foldername/$jobname"
	checkstatus $jobname $channelname $jobfile
}

recordandshow () {
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname
	echo "Connecting to sopcast"
	nohup sp-sc $channelname 8901 8902 > "$appfolder/log.txt"  &
	jobname=$(zenity --entry --text="Save file name. \n\nNO SPACES")
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	if [ -z "$foldername" ]; then echo "Folder name read failed"; return; fi
	sopstarted="no"
	(while [ $sopstarted != "yes" ]; do
		grep "I START " "$appfolder/log.txt"
		if [ $? == "1" ]; then
			echo "Sopcast not started"
			sleep 1
		else
			echo "Sopcast connected"
			sopstarted="yes"
		fi
	done) | zenity --progress --pulsate --text="Connecting to Sopcast channel: \n$channelname" --auto-close --no-cancel
	sleep 1
	echo "Starting VLC"
	nohup vlc http://127.0.0.1:8902/tv.asf &
	echo Create new recording	
	nohup cvlc http://127.0.0.1:8902/tv.asf --sout=file/asf:"$foldername/$jobname".asf &
	jobfile="$foldername/$jobname"
	echo "BE SURE TO KILL SP-SC WHEN YOU ARE DONE 'killall sp-sc'"
	checkstatus $jobname $channelname $jobfile
}

stoprec () {
	zenity --question --text="Do you know the job name?"
	if [ $? == "0" ]; then
		jobname=$(zenity --entry --text="Please type the job name to stop.")
		if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
		killjob $jobname
	else
		zenity --question --text="Do you also want to clear crontab of all jobs?"
		if [ $? == "0" ]; then
			cleancron
		else
			echo "Stopping VLC Recording" && killall vlc
			echo "Stopping CVLC" && killall cvlc
			echo "Stopping Sopcast Connection" && killall sp-sc
		fi
	fi
}

advancemenu () {
	quitadv="no"

	while [ $quitadv != "yes" ]; do				
		choice=$(zenity --list --height=225 --width=225 --text="Choose what operation you would like to complete." \
			--column=Channel --column=Name \
			"1" "Clean Crontab" \
			"2" "Clean nohup file" \
			"3" "asdfasdf" \
			"4" "test" \
			"5" "Back" \
		)
		case $choice in
			1) cleancron ;;
			2) rm nohup.out ;;
			3) echo "test" ;;
			4) echo "test" ;;
			5) quitadv="yes" ;;
			*) echo "\"$choice\" is not valid"
			sleep 1 ;;
		esac
	done
}

cleancron () {
	echo "KILL KILL KILL"
		#kill still recording sh session.
		psid="start"
		while [ "$psid" != "end" ]; do
			psid=$(ps ax | grep -v grep | grep "sopdvr.sh $jobname start"| awk '{print$1}')
			if [ -z "$psid" ]; then psid="end"; fi
			echo "Process ID = $psid"
			kill -9 $psid
		done
		echo "Script Killed"
		psid="start"
		while [ "$psid" != "end" ]; do
			psid=$(ps ax | grep -v grep | grep "sopdvr.sh $jobname start"| awk '{print$1}')
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
}

###USER MENU####
if [ -z "$1" ]; then

	quit="no"
	
	while [ $quit != "yes" ]; do				
		choice=$(zenity --list --height=310 --width=225 --text="Choose what operation you would like to complete." \
		--column=Channel --column=Name \
		"1" "Job Creation" \
		"2" "Instant Job" \
		"3" "Just Record Now!" \
		"4" "Record + Show" \
		"5" "Show Only" \
		"6" "Stop Recording" \
		"7" "Advance" \
		"8" "Quit" \
	)
		case $choice in
			1) creation ;;
			2) instantcreate ;;
			3) recordonly ;;
			4) recordandshow ;;
			5) showonly ;;
			6) stoprec ;;
			7) advancemenu ;;
			8) quit="yes" ;;
			"") echo "Quitting" ; quit="yes" ;;
			*) echo "$choice is not valid"
			sleep 1 ;;
		esac
	done

else
	## If arguments are sent with opening file load a job or kill a job. $2 will be the kill job flag and $1 is job name. 
	recordnow $1 $2
fi

