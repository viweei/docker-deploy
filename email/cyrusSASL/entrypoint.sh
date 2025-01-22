#!/bin/sh

# 启动 OpenRC 初始化系统
openrc default

# 启动 saslauthd 服务
rc-service saslauthd start

# 保持前台进程运行以保持容器活动
tail -f /dev/null