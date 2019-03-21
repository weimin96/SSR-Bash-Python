#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

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
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

AutoIptables(){
    rsum=`date +%s%N | md5sum | head -c 6`
    echo "使用前请注意，该功能会重置防火墙配置，已有连接可能会被中断。"
    echo -e "在下面输入\e[31;49m $rsum \e[0m表示您已知晓风险并同意继续"
    read readsum
    if [[ ${readsum} == ${rsum} ]];then
        netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq >> ./port.conf
        bash /usr/local/SSR-Bash-Python/iptables2.sh
        if [[ ${OS} =~ ^Ubuntu$|^Debian$  ]];then
            iptables-restore < /etc/iptables.up.rules
            for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
            for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
            iptables-save > /etc/iptables.up.rules
        fi
        if [[ ${OS} == CentOS  ]];then
           if [[ $CentOS_RHEL_version == 7  ]];then
               iptables-restore < /etc/iptables.up.rules
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
               iptables-save > /etc/iptables.up.rules
           else
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
               /etc/init.d/iptables save
               /etc/init.d/iptables restart
           fi
        fi
        rm -f ./port.conf
    else
        echo "输入错误，退出!"
        bash /usr/local/SSR-Bash-Python/dev.sh
        exit 0
    fi
}
echo "高级功能"
echo "1.BBRplus加速"
echo "2.一键封禁BT下载，SPAM邮件流量（无法撤销）"
echo "3.防止暴力破解SS连接信息 (重启后失效)"
echo "4.加速方案"
echo "直接回车返回上级菜单"
while :; do echo
	read -p "请选择： " devc
	[ -z "$devc" ] && ssr && break
	if [[ ! $devc =~ ^[1-4]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break
	fi
done

if [[ $devc == 1 ]];then
	wget "https://github.com/cx9208/bbrplus/raw/master/ok_bbrplus_centos.sh" && chmod +x ok_bbrplus_centos.sh && ./ok_bbrplus_centos.sh
fi

if [[ $devc == 2 ]];then
  wget -q -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh banall
  rm -rf ban_iptables.sh
fi

if [[ $devc == 3 ]];then
	nohup tail -F /usr/local/shadowsocksr/ssserver.log | python autoban.py >log 2>log &
fi

if [[ $devc == 4 ]];then
  wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
fi

exit 0
