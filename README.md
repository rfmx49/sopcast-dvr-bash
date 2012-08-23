sopcast-dvr-bash
================

Sopcast DVR allows you to record sopcast channels in Ubuntu. Schedule sopcast jobs with crontab.

Before starting make sure that your crontab file has been created run crontab -e and make sure it shows your cron tab.

System requirements:
-uses zenity dialogue boxes.
-install scripts use apt-get for vlc cvlc zenity
--if not using apt-get then you can manually install these applications.
-script for installing sopcast sp-sc installs to /usr/bin

FEATURES
-Create a scheduled recording within you users cron tab.
-Create a recording starting now
-Record and also show the stream in VLC player
-Option to just watch the stream with no recording
-Install sopcast command line and gui utility.

