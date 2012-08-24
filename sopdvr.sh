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
		echo $portfound
	done
	echo "Random $ranport"
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
		echo "$appfolder/$jobname.conf"
		jobfile=$(<"$appfolder/$jobname.conf")
		set -- $jobfile
		jobportin=$4
		jobportout=$5
		jobchannel=$3
		killjob $jobname $jobchannel $jobportin $jobportout
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
	echo "Create new recording"
	jobname=$(zenity --entry --text="Job name. \n\nNO SPACES")
	if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
	echo $jobname > "$appfolder/$jobname.conf"
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	if [ -z "$foldername" ]; then echo "Folder name read failed";rm "$appfolder/$jobname.conf"; return; fi
	echo $foldername/$jobname >> "$appfolder/$jobname.conf"
	randomport
	jobportin=$ranport
	randomport
	jobportout=$ranport
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname >> "$appfolder/$jobname.conf"
	echo $jobportin >> "$appfolder/$jobname.conf"
	echo $jobportout >> "$appfolder/$jobname.conf"
	#Get crontab info
	cronstart $jobname
	if [ $? == 1 ]; then echo "Cron start failed"; return; fi
	cronend $jobname $crondate $cronmonth $cronday $cronhour $cronminute
	if [ $? == 1 ]; then echo "Cron end failed"; return; fi
	zenity --info --text="Job creation completed"
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
	randomport
	jobportin=$ranport
	randomport
	jobportout=$ranport
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; rm "$appfolder/$jobname.conf"; return; fi
	echo $channelname
	echo $channelname >> "$appfolder/$jobname.conf"
	echo $jobportin >> "$appfolder/$jobname.conf"
	echo $jobportout >> "$appfolder/$jobname.conf"
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

		#checkstatus $jobname $jobchannel $jobfile $jobportin $jobportout
	fi
}

checkstatus () {
	###Check for file creation
	jobname=$1
	jobchannel=$2
	jobfile=$3
	jobportin=$4
	jobportout=$5
	showaswell=$6
	check=1
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
	echo "Connection started: Checking connections."
	while [ $check -le "$maxtime" ]; do
		ps ax | grep -v grep | grep "sp-sc.$jobchannel.$jobportin.$jobportout$"
		if [ $? == "0" ]; then
			ps ax | grep -v grep | grep "http://127.0.0.1:$jobportout/tv.asf :demux=dump"
			if [ $? == "0" ]; then
				echo "$jobfile.asf"
				#File check is the size of the file currently filesize is previous.
				filecheck=$(stat -c%s "$jobfile.asf")
				echo $filecheck "is newfile size"
				if [ "$filecheck" != "$filesize" ]; then
					filesize=$filecheck
					check=$((check+1))
					fail="false"
				else
					fail="true"
					echo "Failed Size not increasing streaming not recording"							
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
				killallreplace $jobchannel $jobportin $jobportout
				if [ "$showaswell" == "true" ]; then
					psid=$(ps ax | grep -v grep | grep "vlc.dhttp://127.0.0.1:$jobportout/tv.asf"| awk '{print$1}')
					echo "Process ID of vlc job = $psid will be killed"
					kill -9 $psid
				fi
				#### Reconnect
				echo "reconnecting to sopcast"
				sopconnect $jobchannel $jobportin $jobportout
				echo "restarting vlc player"
				sleep 3				
				nohup cvlc "http://127.0.0.1:$jobportout/tv.asf" :demux=dump :demuxdump-file="$jobfile$newfile".asf &
				if [ "$showaswell" == "true" ]; then
					nohup vlc "http://127.0.0.1:$jobportout/tv.asf"
				fi
				newfile=$((nefile+1))
				filesize="0"
			fi		
		fi
		#####TIME TO WAIT BETWEEN CHECKS
		sleep 30
	done
}

showonly () {
	randomport
	jobportin=$ranport
	randomport
	jobportout=$ranport
	sopchannel
	if [ $? == 1 ]; then echo "sopchannel failed"; return; fi
	echo $channelname
	echo "Connecting to sopcast"
	sopconnect $channelname $jobportin $jobportout
	echo "Starting VLC"
	vlc "http://127.0.0.1:$jobportout/tv.asf"
	killallreplace $jobchannel $jobportin $jobportout #replace
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
	(while [ $sopstarted != "yes" ]; do
		grep "I START " "$appfolder/sop.log"
		if [ $? == "1" ]; then
			echo "Sopcast not started"
			sleep 1
			timeout=$((timeout+1))
			if [ "$timeout" == "32" ]; then
				nohup zenity --error --text="Connection timed out 30s" &
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
	done) | zenity --progress --pulsate --text="Connecting to Sopcast channel: \n$1" --auto-close --no-cancel
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

recordandshow () {
	randomport
	jobportin=$ranport
	randomport
	jobportout=$ranport
	sopchannel
	showandtell="true"
	if [ $? == 1 ]; then echo "sopchannel failed"; return; fi
	echo $channelname
	echo "Connecting to sopcast"
	nohup sp-sc $channelname $jobportin $jobportout > "$appfolder/sop.log"  &
	jobname=$(zenity --entry --text="Save file name. \n\nNO SPACES")
	if [ -z "$jobname" ]; then 
		echo "Job name read failed"
		psid=$(ps ax | grep -v grep | grep "sp-sc.$channelname $jobportin $jobportout"| awk '{print$1}')
		echo "Process ID of sp-sc job = $psid will be killed"
		kill -9 $psid
		return
	fi
	zenity --info --text="Choose the folder you would like to save recording to"
	foldername=$(zenity --file-selection --directory)
	echo $channelname >> "$appfolder/$jobname.conf"
	echo $jobportin >> "$appfolder/$jobname.conf"
	echo $jobportout >> "$appfolder/$jobname.conf"
	if [ -z "$foldername" ]; then echo "Folder name read failed"; return; fi
	sopstarted="no"
	timeout=1
	(while [ $sopstarted != "yes" ]; do
		grep "I START " "$appfolder/sop.log"
		if [ $? == "1" ]; then
			echo "Sopcast not started"
			sleep 1
			timeout=$((timeout+1))
			if [ "$timeout" == "32" ]; then
				nohup zenity --error --text="Connection timed out 30s" &
				psid=$(ps ax | grep -v grep | grep "sp-sc.$channelname $jobportin $jobportout"| awk '{print$1}')
				echo "Process ID of sp-sc job = $psid will be killed"
				kill -9 $psid
				timeout=1
				nohup sp-$channelname $jobportin $jobportout > "$appfolder/sop.log" &
				sleep 3
				
			fi
		else
			echo "Sopcast connected"
			sopstarted="yes"
		fi
	done) | zenity --progress --pulsate --text="Connecting to Sopcast channel: \n$channelname" --auto-close --no-cancel
	sleep 1
	echo "Starting VLC"
	nohup vlc "http://127.0.0.1:$jobportout/tv.asf" &
	echo Create new recording	
	nohup cvlc "http://127.0.0.1:$jobportout/tv.asf" :demux=dump :demuxdump-file="$foldername/$jobname".asf &
	jobfile="$foldername/$jobname"
	echo "BE SURE TO KILL SP-SC WHEN YOU ARE DONE 'killall sp-sc'"
	nohup zenity --info --text="To stop you will have to relaunch the application and choose the Stop recording option in the menu remember the job name is $jobname" &
	checkstatus $jobname $channelname $jobfile $jobportin $jobportout $showandtelll
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
	zenity --question --text="Do you know the job name?"
	if [ $? == "0" ]; then
		jobname=$(zenity --entry --text="Please type the job name to stop.")
		if [ -z "$jobname" ]; then echo "Job name read failed"; return; fi
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

	while [ $quitadv != "yes" ]; do				
		choice=$(zenity --list --height=225 --width=225 --text="Choose what operation you would like to complete." \
			--column=Channel --column=Name \
			"1" "Clean Crontab" \
			"2" "Clean nohup file" \
			"3" "Install Sopcst player GUI" \
			"4" "test" \
			"5" "Back" \
		)
		case $choice in
			1) cleancron ;;
			2) rm nohup.out ;;
			3) sopguiinstall ;;
			4) randomport; echo $ranport ;;
			5) quitadv="yes" ;;
			"") echo "Quitting" ; quitadv="yes" ;;
			*) echo "\"$choice\" is not valid"
			sleep 1 ;;
		esac
	done
}

sopguiinstall () {
	zenity --question --text="Do you want to install sopcast Player Gui?"
	if [ $? == "0" ]; then
		echo "Install"
		echo "Downloading sopcast gui"
		rm sopcast-player-0.8.5.tar.gz*
		wget "http://sopcast-player.googlecode.com/files/sopcast-player-0.8.5.tar.gz"
		if [ $? == "0" ]; then
			echo "Download of sopcast-player-0.8.5.tar.gz completed"
		else
			zenity --error --text="Download of sp-sc FAILED"
			rm sp-auth.tgz*
			return 1
		fi
		echo "Extracting"
		sleep 2
		tar xfzv "sopcast-player-0.8.5.tar.gz"
		if [ $? == "0" ]; then
			echo "Extraction of sopcast-player-0.8.5.tar.gz completed"
		else
			zenity --error --text="Extraction of sopcast-player-0.8.5.tar.gz FAILED"
			echo "Sudo command sop-player: rm -r sopcast-player-0.8.5.tar.gz sop-player"			
			sudo rm -r sopcast-player-0.8.5.tar.gz sop-player
			return 1
		fi
		cd sopcast-player
		make
		echo "Sudo command sop-player: sudo make install"
		sudo make install
		if [ $? == "0" ]; then
			echo "Copying of  completed"
		else
			zenity --error --text="Copying of  FAILED"
			echo "Sudo command sop-player: rm -r sopcast-player-0.8.5.tar.gz sop-player"			
			sudo rm -r sopcast-player-0.8.5.tar.gz sop-player
			return 1
		fi
		echo "installed"
		echo "Sudo command sop-player: rm -r sopcast-player-0.8.5.tar.gz sop-player"			
		sudo rm -r sopcast-player-0.8.5.tar.gz sop-player							
	else
		return 0
	fi
}

softwarecheck () {
	echo "Checking for zenity"
	swcheck=$(zenity --version)	
	if [ -z "$swcheck" ]; then		
		echo "ZENITY NOT FOUND INSTALL ZENITY! sudo apt-get install zenity"
		wait 1
		echo "Do you want to install zenity? y or n"
		read zenans
			if [ "$zenans" == "y" ]; then
				echo "command to be run: sudo apt-get install zenity"
				sudo apt-get install zenity
			else
				return 1
			fi
		
	else
		echo "zenity installed"
	fi
	
	echo "Checking for sp-sc"
	swcheck=$(sp-sc --version)	
	if [ -z "$swcheck" ]; then		
		zenity --question --height=100 --width=400 --text="Sopcast not instaled correctly:\n\nsp-sc command not found\n\nDo you want to skip this check?\n\n\nChoose no for an option to install software"
		if [ $? == "1" ]; then
			zenity --question --text="Do you want to install missing software now?"
			if [ $? == "0" ]; then
				echo "Install"
				echo "Downloading sopcast sp-sc-auth / sp-sc"
				rm sp-auth.tgz*
				wget "http://download.easetuner.com/download/sp-auth.tgz"
				if [ $? == "0" ]; then
					echo "Download of sp-sc completed"
				else
					zenity --error --text="Download of sp-sc FAILED"
					rm sp-auth.tgz*
					return 1
				fi
				
				echo "Downloading libstdcpp5"
				rm libstdcpp5.tgz*
				wget "http://www.sopcast.com/download/libstdcpp5.tgz"
				if [ $? == "0" ]; then
					echo "Download of libstdcpp5.tgz completed"
				else
					zenity --error --text="Download of libstdcpp5.tgz FAILED"
					rm libstdcpp5.tgz*
					return 1
				fi
				echo "Extracting"
				sleep 2
				tar xfzv "sp-auth.tgz"
				if [ $? == "0" ]; then
					echo "Extraction of sp-auth.tgz completed"
				else
					zenity --error --text="Extraction of sp-auth.tgz FAILED"
					rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth
					return 1
				fi
				tar xfzv "libstdcpp5.tgz"
				if [ $? == "0" ]; then
					echo "Extraction of libstdcpp5.tgz completed"
				else
					zenity --error --text="Extraction of libstdcpp5.tgz FAILED"
					rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth
					return 1
				fi
				echo "Sudo command: sudo cp -a usr/lib/libstdc++.so.5* /usr/lib"
				echo "Sudo command 2: sudo cp -a sp-auth/sp-sc-auth /usr/bin/sp-sc"
				sudo cp -a usr/lib/libstdc++.so.5* /usr/lib
				if [ $? == "0" ]; then
					echo "Copying of libstdcpp5.tgz completed"
				else
					zenity --error --text="Copying of libstdcpp5.tgz FAILED"
					rm -r libstdcpp5.tgz* sp-auth.tgz* usr sp-auth
					return 1
				fi
				sudo cp -a sp-auth/sp-sc-auth /usr/bin/sp-sc
				if [ $? == "0" ]; then
					echo "Copying of sp-auth/sp-sc-auth to /usr/bin completed"
				else
					zenity --error --text="Copying of sp-auth/sp-sc-auth to /usr/bin FAILED"
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
		zenity --question --text="VLC player not instaled correctly:\n\nvlc command not found\n\nDo you want to skip this check?\n\n\nChoose no for an option to install software"
		if [ $? == "1" ]; then
			zenity --question --text="Do you want to install missing software now?"
			if [ $? == "0" ]; then
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
		zenity --question --text="Commandline vlc not instaled correctly:\n\ncvlc command not found\n\nDo you want to skip this check?\n\n\nChoose no for an option to install software"
		if [ $? == "1" ]; then
			zenity --question --text="Do you want to install missing software now?"
			if [ $? == "0" ]; then
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
	softwarecheck
	clear
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

