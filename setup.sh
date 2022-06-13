#
# Donnie V. Savage
# 10 Nov, 2021
#

if [[ "$EUID" = 0 ]]; then
    echo "Do not run as root"
    exit
fi

echo Fixing Shared library error
if [ "`grep -c "/usr/local/lib" /etc/ld.so.conf`" = "0" ]; then
    sudo echo include /usr/local/lib >> /etc/ld.so.conf
    ldconfig
fi

echo Install DEVTOOLS
sudo apt-get install git autoconf automake libtool make \
  libreadline-dev texinfo libjson-c-dev pkg-config bison flex \
  libc-ares-dev python3-dev python3-pytest python3-sphinx build-essential \
  libsnmp-dev libcap-dev libelf-dev

echo Install LIBYANG2
cd ~/Downloads

wget 'https://ci1.netdef.org/artifact/LIBYANG-LIBYANG2/shared/build-150/Debian-10-x86_64-Packages/libyang-dev_2.0.0-0_amd64.deb'
wget 'https://ci1.netdef.org/artifact/LIBYANG-LIBYANG2/shared/build-150/Debian-10-x86_64-Packages/libyang-tools_2.0.0-0_amd64.deb'
wget 'https://ci1.netdef.org/artifact/LIBYANG-LIBYANG2/shared/build-150/Debian-10-x86_64-Packages/libyang2_2.0.0-0_amd64.deb'

sudo apt install ./libyang2_2.0.0-0_amd64.deb
sudo apt install ./libyang-tools_2.0.0-0_amd64.deb
sudo apt install ./libyang-dev_2.0.0-0_amd64.deb

echo Install GROUPS
sudo addgroup --system --gid 92 frr
sudo addgroup --system --gid 85 frrvty
sudo adduser --system --ingroup frr --home /var/opt/frr/ --gecos "FRR suite" --shell /bin/false frr
sudo usermod -a -G frrvty frr

echo Add Me to FRR GROUPS
sudo usermod -a -G frr $USER
sudo usermod -a -G frrvty $USER


echo Clone REPOS
cd ~/devel

git clone git@github.com:diivious/eigrpd.git
git clone https://github.com/frrouting/frr.git frr
git clone https://github.com/frrouting/frr.git frr-orig

echo Config FRR
cd ~/devel/frr
   ./bootstrap.sh
   ./configure \
       --localstatedir=/var/opt/frr \
       --sbindir=/usr/lib/frr \
       --sysconfdir=/etc/frr \
       --enable-multipath=64 \
       --enable-user=frr \
       --enable-group=frr \
       --enable-vty-group=frrvty \
       --enable-configfile-mask=0640 \
       --enable-logfile-mask=0640 \
       --enable-fpm \
       --with-pkg-git-version \
       --with-pkg-extra-version=

echo Build FRR
make -j 8

echo Check FRR
make check

echo install FRR
sudo make install

echo Create CONFIGS
sudo install -m 775 -o frr -g frrvty -d /etc/frr
sudo install -m 640 -o frr -g frrvty /dev/null /etc/frr/vtysh.conf

sudo install -m 755 -o frr -g frr -d /var/log/frr
sudo install -m 755 -o frr -g frr -d /var/opt/frr

echo Create EIGRPD CONFIG
echo 'service integrated-vtysh-config' > /etc/frr/vtysh.conf
sudo cp ~/devel/eigrpd-tools/etc.frr.frr.conf /etc/frr/frr.conf

echo Cheching /etc/services
if [ "`grep 2613 /etc/services`" = "" ]; then
 echo You need to add content of etc.services to /etc/services
fi

echo Start FRR Service
sudo cp ~/devel/eigrpd-tools/etc.frr.daemons /etc/frr/daemons
sudo systemctl daemon-reload

sudo cp ~/devel/eigrpd-tools/frr.service /etc/systemd/system/frr.service
sudo systemctl start frr
