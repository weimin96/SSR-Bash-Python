#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd /usr/local/shadowsocksr
cat /usr/local/SSR-Bash-Python/user/userData | while read line
do
    if [[ $line == -* ]]; then
        echo $line
        array=(${line//|/ })
        uname=$array[1]
        checkuid=$(python mujson_mgr.py -l -u $uname 2>/dev/null)
        if [[ ${checkuid} ]];then
             "用户${uname}已存在"
			continue
		fi

        uport=$array[2]
        port=`netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq | grep '$uport' `
		if [[ ${port} ]];then
			echo "端口${port}已存在"
			continue
		fi
        upass=$array[3]
        # 加密方式
        um1=$array[4]
        # 协议
        ux1=$array[5]
        # 混淆
        uo1=$array[6]
        # 限流
        ut=$array[7]
        # 允许连接数
        uparam=$array[8]
        # 限速值
        us=$array[9]
        echo "===================="
		echo "用户名: $uname"
		echo "远程端口号: $uport"
		echo "密码: $upass"
		echo "加密方法: $um1"
		echo "协议: $ux1"
		echo "混淆方式: $uo1"
		echo "流量: $ut GB"
		echo "允许连接数: $uparam"
		echo "最大速度: $us kb/s"
		echo "===================="
    fi
done
# python mujson_mgr.py -a -u $uname -p $uport -k $upass -m $um1 -O $ux1 -o $uo1 -t $ut -S $us -G $uparam
