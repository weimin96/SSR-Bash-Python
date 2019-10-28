基于 https://github.com/FunctionClub/SSR-Bash-Python 
## 原有功能

- 一键开启、关闭SSR服务
- 添加、删除、修改用户端口、密码和连接数限制
- 支持傻瓜式用户添加
- 自由限制用户端口流量使用及端口网速
- 自动修改防火墙规则
- 自助修改SSR加密方式、协议、混淆等参数
- 自动统计，方便查询每个用户端口的流量使用情况
- 自动安装Libsodium库以支持Chacha20等加密方式
- 支持用户二维码生成
- 支持一键构建ss-panel-V3-mod,前端后端自动对接，无需额外操作
- 傻瓜式的BBR、锐速、LotServer一键构建
- 可自定义的服务器巡检，故障自动重启服务，确保链接稳定有效
- 可对配置进行备份、还原，迁移服务器只需在新服务器上还原配置，无需重复设置
- 支持IP黑名单功能，可通过端口查询，直接加入黑名单，禁止该IP访问服务器的所有服务
- 允许针对不同用户限制帐号有效期，到期自动删除帐号

## 新增功能

- 定时清空用户流量
- 文件快速导入用户
- 查看所有端口的用户链接状态
- 版本更新
- 整合bbr plus加速方案

## 安装&更新
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/weimin96/SSR-Bash-Python/master/install.sh && bash install.sh

## 卸载
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/weimin96/SSR-Bash-Python/master/install.sh && bash install.sh uninstall
