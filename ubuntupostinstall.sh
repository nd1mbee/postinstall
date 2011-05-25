#!/bin/bash
#
#
# Script initial de Nicolargo - 05/2011
# GPL
#
# Syntaxe: # sudo ./ubuntupostinstall.sh
VERSION="1.5"

#=============================================================================
# Liste des applications à installer: A adapter a vos besoins
# Voir plus bas les applications necessitant un depot specifique
LISTE=""
# Developpement
LISTE=$LISTE" vim git"
# Java: http://doc.ubuntu-fr.org/java
LISTE=$LISTE" sun-java6-jre sun-java6-plugin sun-java6-fonts"
# Multimedia
LISTE=$LISTE" x264 ffmpeg2theora oggvideotools mplayer hugin nautilus-image-converter gimp gimp-save-for-web ogmrip mppenc faac flac vorbis-tools faad lame nautilus-script-audio-convert cheese nautilus-arista"
# Network
LISTE=$LISTE" iperf ifstat wireshark tshark arp-scan htop netspeed nmap netpipe-tcp thunderbird"
# Systeme
LISTE=$LISTE" gparted"
# Web
LISTE=$LISTE" pidgin pidgin-facebookchat pidgin-plugin-pack flashplugin-installer"
#=============================================================================

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi


# On commence par installer aptitude
#-----------------------------------

apt-get -y install aptitude

# Ajout des depots
#-----------------

#UBUNTUVERSION=`lsb_release -c | awk '{print$2}'`
UBUNTUVERSION=`lsb_release -cs`
echo "Ajout des depots pour Ubuntu $UBUNTUVERSION"

# Rawstudio
apt-add-repository ppa:rawstudio/ppa
LISTE=$LISTE" rawstudio "

# Rawstudio
apt-add-repository ppa:paul-climbing/ppa
LISTE=$LISTE" winff "

# GStreamer, daily build
add-apt-repository ppa:gstreamer-developers
LISTE=$LISTE" "`aptitude -w 2000 search gstreamer | cut -b5-60 | xargs -eol`

# Shutter, outil de capture d'ecran
add-apt-repository ppa:shutter
LISTE=$LISTE" shutter"

# Chromium, LE navigateur Web (dev-channel PPA)
add-apt-repository ppa:chromium-daily/dev
LISTE=$LISTE" chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra chromium-codecs-ffmpeg-nonfree"

# X264 / THEORA
add-apt-repository ppa:nilarimogard/webupd8

# VLC 
add-apt-repository ppa:ferramroberto/vlc
LISTE=$LISTE" vlc vlc-plugin-pulse"
# VLMC
add-apt-repository ppa:webupd8team/vlmc
LISTE=$LISTE" vlmc"


# Terminator
add-apt-repository ppa:gnome-terminator/ppa
LISTE=$LISTE" terminator"


# Depot partenaires 
egrep '^deb\ .*partner' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]
then
	echo "## 'partner' repository"
	echo -e "deb http://archive.canonical.com/ubuntu $UBUNTUVERSION partner\n" >> /etc/apt/sources.list
fi	

# WebUpd8 (lots of fresh software)
add-apt-repository ppa:nilarimogard/webupd8

# Nautilus elementary 
add-apt-repository ppa:am-monkeyd/nautilus-elementary-ppa

# VirtualBox 4.0
egrep '^deb\ .*virtualbox' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]
then
	echo "deb http://download.virtualbox.org/virtualbox/debian $UBUNTUVERSION contrib" | tee -a /etc/apt/sources.list
	wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -
fi
LISTE=$LISTE" virtualbox-4.0 dkms"

# LibreOffice
add-apt-repository ppa:libreoffice/ppa
LISTE=$LISTE" libreoffice libreoffice-gnome"

# Handbrake
add-apt-repository ppa:stebbins/handbrake-releases
LISTE=$LISTE" handbrake-gtk"

# Mise a jour de la liste des depots
#-----------------------------------

echo "Mise a jour de la liste des depots"

# Update 
aptitude update 2>&1 | grep NO_PUBKEY | perl -pwe 's#^.+NO_PUBKEY (.+)$#$1#' | xargs apt-key adv --recv-keys --keyserver keyserver.ubuntu.com

# Upgrade
aptitude dist-upgrade

# Installations additionnelles
#-----------------------------

echo "Installation des logiciels suivants: $LISTE"

aptitude -y install $LISTE

# DVD
#sudo sh /usr/share/doc/libdvdread4/install-css.sh

cd -

# Custom du systeme
gconftool-2 --type Boolean --set /desktop/gnome/interface/menus_have_icons True
gsettings set com.canonical.Unity.Panel systray-whitelist "['all']"

# Custom .bashrc
cat >> ~/.bashrc << EOF
alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
export MOZ_DISABLE_PANGO=1
EOF
source ~/.bashrc

# Restart Nautilus
nautilus -q

# Fin du script
#---------------

