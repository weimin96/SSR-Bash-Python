#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd /usr/local/shadowsocksr
cat /usr/local/SSR-Bash-Python/user/userData | while read line
do
    if [[ $line == -* ]]; then
        echo $line
        array=(${line//|/ })
        for var in ${array[@]}
        do
            uname=$var[1]
            checkuid=$(python mujson_mgr.py -l -u $uname 2>/dev/null)
            if [[ ${checkuid} ]];then
            	echo "用户${uname}已存在"
				break
			fi

            uport=$var[2]
            port=`netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq | grep "$uport"`
			if [[ -z ${port} ]];then
				echo "端口${port}已存在"
				break
			fi
            upass=$var[3]
            # 加密方式
            um1=$var[4]
            # 协议
            ux1=$var[5]
            # 混淆
            uo1=$var[6]
            # 限流
            ut=$var[7]
            # 允许连接数
            uparam=$var[8]
            # 限速值
            us=$var[9]

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
        done
    fi
done
# python mujson_mgr.py -a -u $uname -p $uport -k $upass -m $um1 -O $ux1 -o $uo1 -t $ut -S $us -G $uparam
