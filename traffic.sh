#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

echo "1.显示所有用户流量信息"
echo "2.清空指定用户流量"
echo "3.清空全部用户流量"
echo "4.定时清空全部用户流量"
echo "直接回车返回上级菜单"

while :; do echo
	read -p "请选择： " tc
	[ -z "$tc" ] && ssr && break
	if [[ ! $tc =~ ^[1-4]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break
	fi
done

if [[ $tc == 1 ]];then
	P_V=`python -V 2>&1 | awk '{print $2}'`
	P_V1=`python -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}'`
	if [[ ${P_V1} == 3 ]];then
		echo "你当前的python版本不支持此功能"
		echo "当前版本：${P_V} ,请降级至2.x版本"
	else
		python /usr/local/SSR-Bash-Python/show_flow.py
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/traffic.sh
fi

if [[ $tc == 2 ]];then
	echo "1.使用用户名"
	echo "2.使用端口"
	echo ""
	while :; do echo
		read -p "请选择： " lsid
		if [[ ! $lsid =~ ^[1-2]$ ]]; then
			echo "输入错误! 请输入正确的数字!"
		else
			break
		fi
	done

	if [[ $lsid == 1 ]];then
		read -p "输入用户名： " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -c -u $uid
		echo "已清空用户名为 ${uid} 的用户流量"
	fi

	if [[ $lsid == 2 ]];then
		read -p "输入端口号： " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -c -p $uid
		echo "已清空端口号为${uid} 的用户流量"
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/traffic.sh
fi

if [[ $tc == 3 ]];then
	cd /usr/local/shadowsocksr
	python mujson_mgr.py -c
	echo "已清空全部用户的流量使用记录"

	echo ""
	bash /usr/local/SSR-Bash-Python/traffic.sh
fi

if [[ $tc == 4 ]];then
	echo "1.定时清空所有流量(每月1号0点1分)"
	echo "2.取消清除"
	while :; do echo
		read -p "输入操作方式： " ct
		if [[ ! $ct =~ ^[1-2]$ ]]; then
			echo "输入错误! 请输入正确的数字!"
		else
			break
		fi
	done
fi

if [[ $ct == 1 ]];then
	echo "1 0 1 * * root /usr/local/SSR-Bash-Python/timeclean.sh" >> /etc/crontab
	isaddtimeclean=$(cat "/etc/crontab"|grep 'timeclean')
	if [[ ! -z ${isaddtimeclean} ]]; then
		echo "设置成功"
	fi
fi

if [[ $ct == 2 ]];then
	sed -i '/.*timeclean.sh$/d' /etc/crontab
	isdeletimeclean=$(cat "/etc/crontab"|grep 'timeclean')
	if [[ -z ${isdeletimeclean} ]]; then
		echo "设置成功"
	fi
fi
