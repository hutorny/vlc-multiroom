# This sctipt install vlc services for each alsa sound card
# Prerequisites - alsa installed, sound cards are operational
# Check permissions to /etc/systemd/system/
if [ ! -w "/etc/systemd/system/" ]; then echo >&2 "Must be root to run script"; fi;
if [ $# -eq 0 ]
then 
#	Missing http password - make a 'dry run'
	echo >&2 "Expecting http password as an argument"; 
	echo >&2 "Performing a dry run"; 
	aplay  -L 2> /dev/null | grep plughw:CARD | bash -c 'i=0; while read f; do echo "vlc@$i -> $f"; i=$((i+1)) ; done;'
	for s in /etc/systemd/system/vlc@* ; do sv=$sv" "$(basename $s .service); done;
	if [ -n "$sv" ]; then
		echo "The following services will be affected"
		systemctl status $sv | grep '[[:space:]]vlc@[[:digit:]]\.service\|Active\|active\|inactive'
	fi
	exit 1;
fi;
if [ ! -w "/etc/systemd/system/" ]; then exit 1; fi;
# Check for presence of vlc user
if ! id -u vlc > /dev/null 2>&1; then
# 	Adding user vlc
	adduser --system --shell /bin/false --group --disabled-password vlc
	usermod vlc --append --groups audio
fi
# Check for presence of vlc user
cp vlc@.service `echo ~vlc`/vlc@.service
cd `echo ~vlc`
if [ ! -w "." ]; then  echo >&2 "`echo ~vlc` is not writeable "; exit 1; fi;
#Creating services for each sound hardware
export HTTP_PASSWORD=$1
aplay  -L 2>/dev/null | grep plughw:CARD | bash -c 'i=0; while read f; do echo "vlc@$i -> $f"; echo "AUDIO_DEVICE=$f" > vlc-$i.svc; echo "HTTP_PASSWORD=$HTTP_PASSWORD" >> vlc-$i.svc; rm -f /etc/systemd/system/vlc@$i.service ; ln -s `echo ~vlc`/vlc@.service /etc/systemd/system/vlc@$i.service ; ln -s /etc/systemd/system/vlc@$i.service /etc/systemd/system/multi-user.target.wants/ 2>/dev/null; i=$((i+1)) ; done;'
systemctl daemon-reload
for s in /etc/systemd/system/vlc@* ; do svc=$svc" "$(basename $s .service); done;
if [ -n "$svc" ]; then
	systemctl restart $svc
	systemctl status $svc | grep '[[:space:]]vlc@[[:digit:]]\.service\|Active\|active\|inactive'
fi
# To disable unnecessary vlc@N services execute
# sudo rm /etc/systemd/system/multi-user.target.wants/vlc@N.service