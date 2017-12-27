# VLC-multiroom

## Introduction

<dl>
  <dt>VLC<a href="https://www.videolan.org/vlc/"><sup>🔗</sup></a></dt>
  <dd>is a VideoLAN's media player, that, among other cool features, facilitates command-line mode of operations and a web interface for remote control</dd>
  <dt>Multiroom<a href="https://en.wikipedia.org/wiki/Whole_House_Audio"><sup>🔗</sup></a></dt>
  <dd>is an audio system that allow for playback and control of music throughout an entire home or building.</dd>
  <dt>SystemD<a href="https://en.wikipedia.org/wiki/Systemd"><sup>🔗</sup></a></dt>
  <dd>is an init system used in Linux distributions to bootstrap the user space and to manage system processes after booting</dd>
  <dt>ALSA<a href="https://en.wikipedia.org/wiki/Advanced_Linux_Sound_Architecture"><sup>🔗</sup></a></dt>
  <dd>is a software framework and part of the Linux kernel that provides an application programming interface (API) for sound card device drivers.</dd>
</dl>

**VLC-multiroom** is a shell script that on a Linux-based media computer configures systemd to run multiple VLC Media Player instances for audio playback via all available ALSA sound cards and for web based remote control with a purpose to make the media computer the core of a multiroom audio system.

## Prerequisites
* A computer running Linux OS with one or more ALSA-compatible audio cards (devices)

## Preparations
Recent Linux distro use PulseAudio as the main audio interface. Unfortunately, PulseAudio is not operable in a system deamon mode and VLC has to be switched to use ALSA audio interface. The script does it via command line, but ALSA drivers initially comes muted and have to be unmuted before using.

### Install ALSA tools
```
sudo apt-get install alsa-base alsa-tools alsa-utils
```

If the graphical environment available, you may also install ALSA GUI tools
```
apt-get install alsa-tools-gui
```

### Unmute all audio outputs
In a graphical environment you may run `qasmixer`, otherwise run `alsamixer` and follow instructions from this [post](http://slopjong.de/2011/08/20/unmute-the-sound-card-using-the-alsa-utils/).
For pure command-line approach please refer to this [post](http://blog.scphillips.com/posts/2013/01/sound-configuration-on-raspberry-pi-with-alsa/)

### Ensure VLC makes audible output via ALSA

* With GUI

Switch VLC to use ALSA interface, please follow this [link](https://www.hecticgeek.com/2012/11/use-alsa-audio-output-in-vlc-to-lower-the-cpu-usage/) for instructions how to do this Start playback and try every hardware card via Audio > Audio Devices menu options

* With command line

List all available ALSA devices:
```
aplay -L
```

From this list the script will use only direct hardware output devices, selected as the following
```
aplay -L | grep plughw:CARD
```

Test an audio device
```
cvlc --novideo --no-sout-video --aout alsa --alsa-audio-device="plughw:CARD=Generic,DEV=0"
```

Repeat this test for every audio device you plan to use.

### Setting up VLC as systemd services
Obtain files from this project
```
wget https://raw.githubusercontent.com/hutorny/vlc-multiroom/master/vlc@.service
wget https://raw.githubusercontent.com/hutorny/vlc-multiroom/master/install-vlc-services.sh
chmod u+x install-vlc-services.sh
```

### Make a dry run
```
./install-vlc-services.sh
```
It should list mapping of VLC instances to audio devices.

### Run the script
```sudo ./install-vlc-services.sh <password>```

where `<password>` is the password to be used for the http interface.

On success it should print the map VLC instance -> audio device and the list of VLC services

Each instance should be accessible via http://hostname:909N
where hostname is the computer's host name or address and N is instance number, e.g. http://192.168.0.100:9090/

## Troubleshooting

Open `vlc@.service` in a text editor and uncomment lines
```
#ExecStartPre=-/bin/mkdir -p /var/log/vlc/
#ExecStartPre=-/bin/chown -R vlc /var/log/vlc/
```
and
```
# -vvv --extraintf=http:logger --file-logging --logfile=/var/log/vlc/vlc-%i.log
```

Restart VLC services
```
systemctl restart vlc@{0..9}
```
Analyze log for errors

Take corrective actions

## Useful links

* http://www.tldp.org/HOWTO/Alsa-sound-6.html
* https://wiki.videolan.org/Documentation:Advanced_Use_of_VLC/
* https://wiki.videolan.org/VLC_command-line_help
