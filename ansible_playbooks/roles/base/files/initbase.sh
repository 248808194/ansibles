#config base system
yum clean all
yum makecache
yum -y groupinstall "Administration Tools"
yum -y groupinstall "Development Libraries"
yum -y groupinstall "System Tools"
yum -y groupinstall "Development Tools"
yum -y groupinstall "chinese-support"
yum -y install rsync
yum -y install cronie
yum -y install vixie-cron
yum -y install svn
yum -y install lrz*
yum -y install vim*
yum -y install libaio-devel
yum -y install gcc
yum -y install nc
yum -y install ntp
yum -y install wget
echo 'LANG="zh_CN.UTF-8"' >  /etc/sysconfig/i18n
chkconfig crond on
/etc/init.d/crond restart
source /etc/sysconfig/i18n

if [ -f /boot/system_init.txt ];then exit 1;fi

#以下变量根据实际情况填写
TimeServerMaster=202.120.2.101
TimeServerSalve=time.windows.com
SSHPort=22
dns_master=202.96.209.133

#network
sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-eth0 > /dev/null 2>&1
sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-eth1 > /dev/null 2>&1

#DNS
echo "
search localdomain
nameserver $dns_master
nameserver 8.8.8.8
" >>/etc/resolv.conf
echo "127.0.0.1 localhost.localdomain localhost">> /etc/hosts
echo '195.154.241.117 rpms.famillecollet.com ' >> /etc/hosts
echo "127.0.0.1 $HOSTNAME " >> /etc/hosts
# kernel mod options optimize
echo "kernel mod config..."
egrep -q -c "ip_conntrack" /etc/modprobe.conf >/dev/null 2>&1 || echo "options ip_conntrack hashsize=1048576" >> /etc/modprobe.conf
#egrep -q -c "_MODIFIED_UUZU_" /etc/sysctl.conf >/dev/null 2>&1 || \

echo "
net.ipv4.ip_forward = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_retrans_collapse = 0
net.ipv4.ip_local_port_range = 1024    65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 50000
net.ipv4.ip_conntrack_max = 2621440
net.ipv4.tcp_timestamps = 0
" >> /etc/sysctl.conf && modprobe ip_conntrack  >/dev/null 2>&1 && sysctl -p >/dev/null 2>&1


#chage PS1
cat > /root/.bashrc  <<'EOF'
export PS1="\h:\w\$ "
export PS1="\[\e[31;1m\]\u@\[\e[32;1m\]\h:\W> \[\e[0m\]"

ulimit -c unlimited

# User specific aliases and functions
alias grep='grep -v grep | GREP_COLOR="1;32;40" LANG=C grep --color=auto'

alias rm='rm -i --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
# Source global definitions

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

EOF
#Disable selinux
echo "selinux config..."
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=targeted/' /etc/selinux/config
setenforce 0 >/dev/null 2>&1

#Boot option
sed -i '/initdefault/s/5/3/g' /etc/inittab || echo "Error: Modify boot option fail."

#Shutdown and stop some services  && start network
echo "Shutdown and stop some services..."
for i in isdn apmd iscsi iscsid microcode_ctl portmap NetworkManager acpid atd auditd avahi-daemon cups haldaemon ip6tables nfslock portreserve pcscd rpcbind rpcgssd rpcidmapd portmap bluetooth xfs anacron autofs cpuspeed firstboot gpm hidd irqbalance kudzu lm_sensors lvm2-monitor mcstrans mdmonitor netfs rawdevices readahead_early restorecond setroubleshoot smartd yum-updatesd;do chkconfig $i off >/dev/null 2>&1;done
/etc/init.d/sendmail start > /dev/null 2>&1;
/etc/init.d/cups stop > /dev/null 2>&1;
/etc/init.d/portmap stop > /dev/null 2>&1;
/etc/init.d/nfslock stop > /dev/null 2>&1
echo "Start netword services on..."
for n in network sshd crond iptables sendmail;do chkconfig $n on > /dev/null 2>&1;done


# Set history
echo "history command config..."
if ! grep "HISTTIMEFORMAT" /etc/profile >/dev/null 2>&1;then echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> /etc/profile;fi
source /etc/profile

# Kill user login from local
ps ax | awk '/tty1/ {if ($2=="tty1")system("kill -9 "$1)}'




cat >> /etc/security/limits.conf << EOF
*       soft    nofile  102400
*       hard    nofile  102400
EOF
#config selinux
setenforce 0
sed -i '/^SELINUX=.*/s#enforcing#disabled#g' /etc/selinux/config
#time sync
cd /root
echo '/usr/sbin/ntpdate time.nist.gov' > /root/timesyn.sh
echo "00 01 * * * /bin/sh /root/timesyn.sh" >> /var/spool/cron/root
/usr/sbin/ntpdate time.nist.gov
#done
touch /boot/system_init.txt