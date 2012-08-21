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
	if [ -z "$channelname" ]; then echo "Value not set, so exiting"; exit; fi
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
		cronmonth=$(zenity --scale \
			--text="Enter month for recording." \
			--value=$(date +%-m) \
			--min-value=1 \
			--max-value=12 \
		)
		cronday=$(zenity --scale \
			--text="Enter day of week for recording.\n\nSunday = 0 --- Saturday = 6" \
			--value=$(date +%-w) \
			--min-value=0 \
			--max-value=6 \
		)
	else
		crondate=$(date +%-d)
		cronmonth=$(date +%-m)
		cronday=$(date +%-W)
	fi
	cronhour=$(zenity --scale \
		--text="Enter hour of day for recording.\n\n24 hour time\nRecommend starting recording earlier than start time" \
		--value=$(date +%-H) \
		--min-value=0 \
		--max-value=23 \
	)
	cronminute=$(zenity --scale \
		--text="Enter minute of hour for recording.\n\nRecommend starting recording earlier than start time" \
		--value=$(date +%-M) \
		--min-value=0 \
		--max-value=60 \
	)
	cron=$(zenity --entry --text="The following will be written to your crontab file.\nStart of recording schedual\nChanges can be made below"\
		--entry-text="$cronminute $cronhour $crondate $cronmonth $cronday $appfolder/sopdvr.sh $jobname start"\
	)
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
		cronmonthend=$(zenity --scale \
			--text="Enter month for recording." \
			--value=$3 \
			--min-value=1 \
			--max-value=12 \
		)
		crondayend=$(zenity --scale \
			--text="Enter day of week for recording end time.\n\nSunday = 0 --- Saturday = 6" \
			--value=$4 \
			--min-value=0 \
			--max-value=6 \
		)
	else
		crondateend=$(date +%-d)
		cronmonthend=$(date +%-m)
		crondayend=$(date +%-W)
	fi
	cronhourend=$(zenity --scale \
		--text="Enter hour of day for recording end time.\n\n24 hour time\nRecommend ending recording later than end time" \
		--value=$5 \
		--min-value=0 \
		--max-value=23 \
	)
	cronminuteend=$(zenity --scale \
		--text="Enter minute of hour for recording end time.\n\nRecommend ending recording later than end time" \
		--value=$6 \
		--min-value=0 \
		--max-value=60 \
	)
	
	#Confirm cron file
	cronend=$(zenity --entry --text="The following will be written to your crontab file.\nEnd of recording schedual\nChanges can be made below"\
		--entry-text="$cronminuteend $cronhourend $crondateend $cronmonthend $crondayend $appfolder/sopdvr.sh $jobname kill"\
	)
	#write crontab file
	tmpfile=/tmp/cron.tmp
	crontab -l > $tmpfile
	echo $cronend >> $tmpfile
	crontab $tmpfile
	rm $tmpfile
}


####JOB CREATION
creation () {
	echo Create new recording
	jobname=$(zenity --entry --text="Job name. \n\nNO SPACES")
	echo $jobname > "$appfolder/$jobname.conf"
	filename=$(zenity --entry --text="Enter save file name.\n\nNO SPACES" --entry-text=$jobname)
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	echo $foldername/$filename >> "$appfolder/$jobname.conf"
	echo $channelname >> "$appfolder/$jobname.conf"
	#Get crontab info
	cronstart $jobname
	cronend $jobname $crondate $cronmonth $cronday $cronhour $cronminute
}

instantcreate () {
	echo Create new recording
	jobname=$(zenity --entry --text="Job name. \n\nNO SPACES")
	echo $jobname > "$appfolder/$jobname.conf"
	filename=$(zenity --entry --text="Enter save file name.\n\nNO SPACES" --entry-text=$jobname)
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	echo $foldername/$filename >> "$appfolder/$jobname.conf"
	sopchannel
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
		sopconnect $channelname
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
	echo "KILL KILL KILL"
	#kill still recording sh session.
	psid=$(ps ax | grep -v grep | grep "/bin/bash ./sopdvr.sh $jobname start"| awk '{print$1}')
	echo "Process ID = $psid"
	kill -9 $psid
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
				sopconnect $channelname
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
	echo $channelname
	echo "Connecting to sopcast"
	sopconnect $channelname
	echo "Starting VLC"
	vlc http://127.0.0.1:8902/tv.asf
	killall sp-sc && echo "Stopping sopcast Connection."
}

sopconnect () {
	nohup sp-sc $1 8901 8902 > "$appfolder/log.txt" &
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
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	nohup cvlc http://127.0.0.1:8902/tv.asf --sout=file/asf:"$foldername/$jobname".asf &
	sopchannel
	echo $channelname
	jobfile="$foldername/$jobname"
	checkstatus $jobname $channelname $jobfile
}

recordandshow () {
	sopchannel
	echo $channelname
	echo "Connecting to sopcast"
	nohup sp-sc $channelname 8901 8902 > "$appfolder/log.txt"  &
	jobname=$(zenity --entry --text="Save file name. \n\nNO SPACES")
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	sopstarted="no"
	while [ $sopstarted != "yes" ]; do
		grep "I START " "$appfolder/log.txt"
		if [ $? == "1" ]; then
			echo "Sopcast not started"
			sleep 1
		else
			echo "Sopcast connected"
			sopstarted="yes"
		fi
	done
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
		psid=$(ps ax | grep -v grep | grep "/bin/bash ./sopdvr.sh * start"| awk '{print$1}')
		echo "Process ID = $psid"
		kill -9 $psid
		echo "Script Killed"
		psid=$(ps ax | grep -v grep | grep "/bin/bash ./sopdvr.sh * kill"| awk '{print$1}')
		echo "Process ID = $psid"
		kill -9 $psid
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

