#!/bin/bash

# Asterisk - non-interactive setup for Debian 8

# Coder: Batur Orkun  - baturorkun@gmail.com

USAGE="./asterisk-install.sh [ --with-dahdi ---with-libpri --with-fax --with-nettools ]"

ASTERISK_VERSION="13"
MYSQL_PASSWD="password"
PHPINI="/etc/php5/apache2/php.ini"

REQUIRED_PACKAGES="vim sox cpp make bison gcc openssl libssl-dev libncurses5-dev libncurses5 zlib1g g++ libxml2-dev libmysqlclient-dev bzip2 mysql-client mysql-server apache2 php5 php5-mysql php5-curl php5-imap php5-ldap phpmyadmin subversion fail2ban vim ntp rsync mplayer clamav clamsmtp clamav-freshclam spamassassin unixodbc unixodbc-dev libmyodbc tcpdump build-essential libnl-dev pkg-config python-m2crypto libgcrypt11-dev lame zip usbmount policycoreutils libsqlite3-dev"
FAX_PACKAGES="unoconv ghostscript libtiff-tools libtiff5-de libtiff5-devv"
NET_TOOLS="bridge-utils wireless-tools isc-dhcp-server"

PACKAGES=$REQUIRED_PACKAGES

for var in "$@"
do
        if [ "$var" == "--help" ]; then
            echo "Usage:" $USAGE
            exit
        fi
        if [ "$var" == "--with-fax" ]; then
            PACKAGES=$PACKAGES" "$FAX_PACKAGES
	        SPANDSP="install"
        fi
        if [ "$var" == "--with-nettools" ]; then
            PACKAGES=$PACKAGES" "$NET_TOOLS
        fi
        if [ "$var" == "--with-dahdi" ]; then
            DAHDI="install"
        fi
        if [ "$var" == "--with-libpri" ]; then
            LIBPRI="install"
        fi
done


echo "Start Installation"

echo "Set Mysql Parameters"

# noninteractive mysql server
debconf-set-selections <<< 'mysql-server mysql-server/root_password password '$MYSQL_PASSWD
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '$MYSQL_PASSWD

# noninteractive phpmyadmin
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/password-confirm password'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/remove-error select abort'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-username string admin'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/db/app-user string'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/install-error select abort'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/remote/host select'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean false'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/remote/port string'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-upgrade boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-user string root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/internal/reconfiguring boolean false'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/missing-db-package-error select abort'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/remote/newhost string'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/upgrade-error select abort'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-reinstall boolean false'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/db/dbname string'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/database-type select mysql'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/internal/skip-preseed boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/upgrade-backup boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-remove boolean'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/passwords-do-not-match error'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/method select unix socket'
debconf-set-selections <<< 'phpmyadmin phpmya dmin/purge boolean false'

#noninteractive postfix install
debconf-set-selections <<< "postfix postfix/mailname string leapvox.leapvox.com"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

echo "Install PACKAGES"

# install packs
apt-get install $PACKAGES -y


# Install DAHDI
if [ "$DAHDI" == "install" ]; then
        echo "Install DAHDI..."
        cd /usr/local/src/

        if [ ! -f /usr/local/src/dahdi-linux-complete-2.6.1+2.6.1-1.2.tar.gz ]; then
                #wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
                wget http://www.atcom.cn/cn/download/cards/ax1d/dahdi-linux-complete-2.6.1+2.6.1-1.2.tar.gz
        fi
        if [ -z "$(find . -type d -name 'dahdi-linux-complete-2.6.1+2.6.1')" ]; then
                tar zxfv /usr/local/src/dahdi-linux-complete-2.6.1+2.6.1-1.2.tar.gz
        fi
        cd /usr/local/src/dahdi-linux-complete-*
        make all && make install && make config
fi

# Install LIBPRI
if [ "$LIBPRI" == "install" ]; then
        echo "Install LIBPRI..."
        cd /usr/local/src/
        if [ ! -f /usr/local/src/libpri-1.4-current.tar.gz ]; then
                wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-1.4-current.tar.gz
        fi
        if [ -z "$(find . -type d -name 'libpri-*')" ]; then
                tar zxfv /usr/local/src/libpri-1.4-current.tar.gz 
        fi         
        cd /usr/local/src/libpri-*
        make all && make install
fi

# Install SPANDSP
if [ "$SPANDSP" == "install" ]; then
        echo "Install SPANDSP..."
        cd /usr/local/src/
        if [ ! -f /usr/local/src/spandsp-0.0.6.tar.gz ]; then
                wget http://soft-switch.org/downloads/spandsp/spandsp-0.0.6.tar.gz
        fi
        if [ ! -d /usr/local/src/spandsp-0.0.6  ]; then
                tar zxfv /usr/local/src/spandsp-0.0.6.tar.gz
        fi
        cd /usr/local/src/spandsp-0.0.6
	./configure --prefix=/usr
	make clean
	make
	make install
fi

# Install Asterisk
echo "Install Asterisk..."
cd /usr/local/src/

if [ ! -f /usr/local/src/asterisk-$ASTERISK_VERSION-current.tar.gz ]; then
       wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-$ASTERISK_VERSION-current.tar.gz
fi

if [ -z "$(find . -type d -name 'asterisk-$ASTERISK_VERSION*')" ]; then
       tar -xzvf asterisk-$ASTERISK_VERSION-current.tar.gz
fi

cd asterisk-$ASTERISK_VERSION*/

./configure 

# make menuselect
make menuselect.makeopts
menuselect/menuselect --enable busydetect_compare_tone_and_silence --enable app_mysql --enable cdr_mysql --enable res_config_mysql menuselect.makeopts

make && make install && make config && make samples

echo "Set checkfs params"
echo "Edit /etc/init.d/checkfs.sh"

perl -pi -e 's/FSCKFIX=no/FSCKFIX=yes/g' /etc/init.d/checkfs.sh
perl -pi -e 's/1$/0/g' /etc/fstab
tune2fs -c 0 -i 0 /dev/sda1

echo "Installation Completed"
IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo "Your IP is $IP"

