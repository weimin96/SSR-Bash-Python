#!/bin/bash
#Set PATH
unset check
for i in `echo $PATH | sed 's/:/\n/g'`
do
        if [[ ${i} == "/usr/local/bin" ]];then
                check="yes"
        fi
done
if [[ -z ${check} ]];then
        echo "export PATH=${PATH}:/usr/local/bin" >> ~/.bashrc
        . ~/.bashrc
fi

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
elif [ ! -z "$(grep 'Arch Linux' /etc/issue)" ];then
    OS=Arch
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi

StopInstall(){
    echo -e "\n安装中断,开始清理文件!"
    sleep 1s
    rm -rf /usr/local/bin/ssr
    rm -rf /usr/local/SSR-Bash-Python
    rm -rf /usr/local/shadowsocksr
    rm -rf ${PWD}/libsodium*
    rm -rf /etc/init.d/ssr-bash-python
    rm -rf /usr/local/AR-B-P-B
    if [[ ${OS} == CentOS  ]];then
        sed -n -i 's#/etc/init.d/ssr-bash-python#d' /etc/rc.d/rc.local
    fi
    if [[ ${OS} == CentOS && ${CentOS_RHEL_version} == 7  ]];then
        systemctl stop iptables.service
        systemctl restart firewalld.service
        systemctl disable iptables.service
        systemctl enable firewalld.service
    fi
    checkcron=$(crontab -l 2>/dev/null | grep "timelimit.sh")
    if [[ ! -z ${checkcron} ]];then
        crontab -l > ~/crontab.bak 1>/dev/null 2>&1
        sed -i "/timelimit.sh/d" ~/crontab.bak 1>/dev/null 2>&1
        crontab ~/crontab.bak 1>/dev/null 2>&1
        rm -rf ~/crontab.bak
    fi
    rm -rf $0
    echo "清理完成!"
}
#收集日志
MakLog(){
    mkdir /tmp/AR_Log
    cd /tmp/AR_Log
    mkdir ./data
    cd data
    cp -R /usr/local/shadowsocksr ./
    cp -R /usr/local/SSR-Bash-Python ./
    cd ..
    mkdir ./log
    cd ./log
    if [[ ${OS} == CentOS ]];then
        cp /var/log/yum.log ./
        cp /var/log/dmesg ./
        cp /var/log/httpd ./
        cp /var/log/mysqld.log ./
        cp /var/log/syslog ./
        cp /var/log/daemon.log ./
        cp /var/log/boot.log ./
        cp /var/log/cron ./
        cp /var/log/secure ./
        cp /var/log/maillog ./
        cp /var/log/spooler ./
        dmesg >> ./dmesg.log
    else
        cp /var/log/apport.log ./
        cp /var/log/boot.log ./
        cp /var/log/dmesg ./
        cp /var/log/dpkg.log ./
        cp /var/log/kern.log ./
        cp /var/log/fsck ./
        cp /var/log/apt/*log ./
        cp /var/log/cpus ./
        dmesg >> ./dmesg.log
    fi
    cd .. && mkdir message && cd message
    echo -e "+++++系统信息+++++
$(date)
-----内核/操作系统/CPU信息-----
$(uname -a)
-----
$(/etc/issue)  $(cat /etc/redhat-release)
-----
$(cat /proc/cpuinfo)

-----计算机名-----
$(hostname)

-----内核模块-----
$(lsmod)

-----环境变量-----
$(env)

-----系统负载-----
$(uptime)

-----内存信息-----
$(cat /proc/meminfo)

-----网络接口属性-----
$(ifconfig)

-----防火墙设置-----
$(iptables -L)

-----路由表-----
$(route -n)

-----IP-----
$(wget -qO- -t1 -T2 ipinfo.io/ip)

-----所有监听端口-----
$(netstat -lntp)

-----已经建立的连接-----
$(netstat -antp)

-----网络统计-----
$(netstat -s)

-----所有进程-----
$(ps -ef)

-----服务状态-----
$(service --status-all)

-----安装的软件包-----
$(rpm -qa)
$(dpkg -l)
" >> messages.txt
cd ..
tar -cjf ~/AR_Log.tar.bz2 /tmp/AR_Log
rm -rf /tmp/AR_Log
}

#日志收集工具
if [[ $1 == "log" ]];then
    echo "日志收集将会收集到您操作系统的部分日志，以便于对错误进行定位，可能会包含您的隐私信息，您确定要收集吗？(Y/N)"
    read -n 1 yn
    if [[ ${yn} == [Yy] ]];then
        rm -rf ~/AR_Log.tar.bz2
        echo -e "\n开始收集日志，通常这将很快完成"
        MakLog 1>/dev/null 2>&1
        echo "收集完成，文件位于/root/AR_Log.tar.bz2"
        exit 0
    else
        exit 2
    fi
fi

#Get Current Directory
workdir=$(pwd)
#Install Basic Tools
if [ ! -e /usr/local/bin/ssr ];then
if [[ $1 == "uninstall" ]];then
    echo "你在开玩笑吗？你都没有安装怎么卸载呀！"
    exit 1
fi
echo "开始部署"
trap 'StopInstall 2>/dev/null && exit 0' 2
sleep 2s
if [[ ${OS} == Ubuntu ]];then
    apt-get update
    apt-get install python -y
    apt-get install python-pip -y
    apt-get install git -y
    apt-get install language-pack-zh-hans -y
    apt-get -y install vnstat bc
    apt-get -y install net-tools dnsutils
    apt-get install build-essential screen curl -y
    apt-get install cron -y
fi
if [[ ${OS} == CentOS ]];then
    yum install python screen curl -y
    yum install python-setuptools -y && easy_install pip -y
    yum install git -y
    yum install bc -y
    yum install vnstat -y
        yum -y install bind-utils
    yum install net-tools -y
    yum groupinstall "Development Tools" -y
    yum install vixie-cron crontabs -y
fi
if [[ ${OS} == Debian ]];then
    apt-get update
    apt-get install python screen curl -y
    apt-get install python-pip -y
    apt-get install git -y
    apt-get -y install net-tools dnsutils
    apt-get -y install bc vnstat
    apt-get install build-essential -y
    apt-get install cron -y
fi
if [[ ${OS} == Arch ]];then
    pacman -Syyu --noconfirm
    pacman -S --noconfirm python screen curl
    pacman -S --noconfirm python-pip
    pacman -S --noconfirm git
    pacman -S --noconfirm bc net-tools bind-tools
    pacman -S --noconfirm gcc cronie
    pacman -S --noconfirm vnstat
    ln -s /etc/iptables/iptables.rules /etc/iptables.up.rules
fi
if [[ $? != 0 ]];then
    echo "安装失败，请稍候重试！"
    exit 1
fi
if [[ ! -e /usr/share/dict/words ]];then
    cd /usr/share/dict
    wget -q https://raw.githubusercontent.com/weimin96/SSR-Bash-Python/master/etc/words
fi
#Install Libsodium
libsodiumfilea="/usr/local/lib/libsodium.so"
libsodiumfileb="/usr/lib/libsodium.so"
if [[ -e ${libsodiumfilea} ]];then
    echo "libsodium已安装!"
elif [[ -e ${libsodiumfileb} ]];then
    echo "libsodium已安装!"
else
    cd $workdir
    wget -q https://raw.githubusercontent.com/weimin96/SSR-Bash-Python/master/etc/libsodium-1.0.17.tar.gz
    tar xvf libsodium-1.0.17.tar.gz
    pushd libsodium-1.0.17
    ./configure --prefix=/usr && make
    make install
    popd
    ldconfig
    cd $workdir && rm -rf libsodium-1.0.17.tar.gz libsodium-1.0.17
#    if [[ ! -e ${libsodiumfile} ]];then
#       echo "libsodium安装失败 !"
#       exit 1
#    fi
fi
cd /usr/local
git clone https://github.com/shadowsocksrr/shadowsocksr.git
cd ./shadowsocksr
git checkout manyuser
git pull
fi

#Install SSR and SSR-Bash
if [ -e /usr/local/bin/ssr ];then
    if [[ $1 == "uninstall" ]];then
        echo "开始卸载"
        sleep 1s
        echo "删除iptables规则"
        ports=$(cat /usr/local/shadowsocksr/mudb.json | grep '"port":' | awk -F":" '{ print $2 }' | sed 's/[,."]//g')
        for port in "${ports}"

do
        if [[ ${OS} =~ ^Ubuntu$|^Debian$|^Arch$ ]];then
            iptables-restore < /etc/iptables.up.rules
            iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT
            iptables -D INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT
            iptables-save > /etc/iptables.up.rules
        fi
        if [[ ${OS} == CentOS ]];then
            if [[ $CentOS_RHEL_version == 7 ]];then
            iptables-restore < /etc/iptables.up.rules
                iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT
            iptables -D INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT
            iptables-save > /etc/iptables.up.rules
        else
                iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT
            iptables -D INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT
            /etc/init.d/iptables save
            /etc/init.d/iptables restart
        fi
        fi
        done
        echo "删除:/usr/local/bin/ssr"
        rm -f /usr/local/bin/ssr
        echo "删除:/usr/local/SSR-Bash-Python"
        rm -rf /usr/local/SSR-Bash-Python
        echo "删除:/usr/local/shadowsocksr"
        rm -rf /usr/local/shadowsocksr
        echo "删除:${PWD}/install.sh"
        rm -f ${PWD}/install.sh
        echo "清理杂项!"
        crontab -l > ~/crontab.bak 1>/dev/null 2>&1
        sed -i "/timelimit.sh/d" ~/crontab.bak 1>/dev/null 2>&1
        crontab ~/crontab.bak 1>/dev/null 2>&1
        rm -rf ~/crontab.bak
        sleep 1s
        echo "卸载完成!!"
        exit 0
    fi
    if [[ ! $yn == n ]];then
        if [[ ! -e /usr/local/SSR-Bash-Python/version.txt ]];then
            yn="y"
        fi
    fi
    if [[ ${yn} == [yY] ]];then
        mv /usr/local/shadowsocksr/mudb.json /usr/local/mudb.json
        rm -rf /usr/local/shadowsocksr
        cd /usr/local
        git clone https://git.fdos.me/stack/shadowsocksr.git
        rm -f ./shadowsocksr/mudb.json
        mv /usr/local/mudb.json /usr/local/shadowsocksr/mudb.json

    fi
    echo "开始更新"
    sleep 1s
    echo "正在清理老版本"
    rm -f /usr/local/bin/ssr
    sleep 1s
    echo "开始部署"
    cd /usr/local/shadowsocksr
    git pull
    git checkout manyuser
fi
if [[ -d /usr/local/SSR-Bash-Python ]];then
    if [[ $yn == [yY] ]];then
        rm -rf /usr/local/SSR-Bash-Python
        cd /usr/local
        git clone https://github.com/weimin96/SSR-Bash-Python.git
    fi
    cd /usr/local/SSR-Bash-Python
    git checkout master
    git pull
else
    cd /usr/local
    git clone https://github.com/weimin96/SSR-Bash-Python.git
    git checkout master
    bashinstall="no"
fi
cd /usr/local/shadowsocksr
bash initcfg.sh
if [[ ! -e /usr/bin/bc ]];then
    if [[ ${OS} == CentOS ]];then
        yum install bc -y
    fi
    if [[ ${OS} == Ubuntu || ${OS} == Debian ]];then
        apt-get install bc -y
    fi
fi
if [[ ${bashinstall} == "no" ]]; then

#Start when boot
if [[ ${OS} == Arch ]];then
cat >/usr/lib/systemd/system/ssr-bash-python.service <<EOF
[Unit]
Description=AutoExec
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=iptables-restore < /etc/iptables.up.rules && bash /usr/local/shadowsocksr/logrun.sh
[Install]
WantedBy=multi-user.target
EOF
systemctl enable ssr-bash-python
fi
if [[ ${OS} == Ubuntu || ${OS} == Debian ]];then
    cat >/etc/init.d/ssr-bash-python <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          SSR-Bash_python
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Should-Start: $network
# Should-Stop: $network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description: SSR-Bash-Python
# Description: SSR-Bash-Python
### END INIT INFO
iptables-restore < /etc/iptables.up.rules
bash /usr/local/shadowsocksr/logrun.sh
EOF
    chmod 755 /etc/init.d/ssr-bash-python
    chmod +x /etc/init.d/ssr-bash-python
    cd /etc/init.d
    update-rc.d ssr-bash-python defaults 95
fi

if [[ ${OS} == CentOS ]];then
    echo "
iptables-restore < /etc/iptables.up.rules
bash /usr/local/shadowsocksr/logrun.sh
" > /etc/rc.d/init.d/ssr-bash-python
    chmod +x  /etc/rc.d/init.d/ssr-bash-python
    echo "/etc/rc.d/init.d/ssr-bash-python" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
fi

#Change CentOS7 Firewall
if [[ ${OS} == CentOS && $CentOS_RHEL_version == 7 ]];then
    systemctl stop firewalld.service
    yum install iptables-services -y
    sshport=$(netstat -nlp | grep sshd | awk '{print $4}' | awk -F : '{print $NF}' | sort -n | uniq)
    cat << EOF > /etc/sysconfig/iptables
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport ${sshport} -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
    systemctl restart iptables.service
    systemctl enable iptables.service
    systemctl disable firewalld.service
fi
fi
#Install SSR-Bash Background
wget -q -N --no-check-certificate -O /usr/local/bin/ssr https://raw.githubusercontent.com/weimin96/SSR-Bash-Python/master/ssr
chmod +x /usr/local/bin/ssr

#Modify ShadowsocksR API
sed -i "s/sspanelv2/mudbjson/g" /usr/local/shadowsocksr/userapiconfig.py
sed -i "s/UPDATE_TIME = 60/UPDATE_TIME = 10/g" /usr/local/shadowsocksr/userapiconfig.py

#INstall Success
ipname=$(wget -qO- -t1 -T2 ipinfo.io/ip)
echo "$ipname" > /usr/local/shadowsocksr/myip.txt
sed -i "s/SERVER_PUB_ADDR = .*$/SERVER_PUB_ADDR = '${ipname}'/g" /usr/local/shadowsocksr/userapiconfig.py

if [[ -e /etc/sysconfig/iptables-config ]];then
        ipconf=$(cat /etc/sysconfig/iptables-config | grep 'IPTABLES_MODULES_UNLOAD="no"')
        if [[ -z ${ipconf} ]];then
                sed -i 's/IPTABLES_MODULES_UNLOAD="yes"/IPTABLES_MODULES_UNLOAD="no"/g' /etc/sysconfig/iptables-config
                echo "安装完成，准备重启"
                sleep 3s
                reboot
        fi
fi
bash /usr/local/SSR-Bash-Python/self-check.sh
echo '安装完成！输入 ssr 即可使用本程序~'
echo "若安装出现异常，或安装完成后无法使用，请手动执行bash ./install.sh log
这将收集日志文件，并将日志文件发送给作者
"
if [[ ${check} != "yes" ]] ;then
        echo "如果你执行 ssr 提示找不到命令，请尝试退出并重新登录来解决"
fi
