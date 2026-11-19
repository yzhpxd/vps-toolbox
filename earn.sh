#!/bin/bash
echo "正在检查 Swap 设置..."
if [ -f /swapfile ]; then
    echo "✅ /swapfile 已存在，跳过创建步骤。"
else
    echo "⚠️ 未检测到 Swap，正在创建 1GB 虚拟内存..."
    # 1. 创建 1GB 文件
    dd if=/dev/zero of=/swapfile bs=1M count=1024
    # 2. 设置权限
    chmod 600 /swapfile
    # 3. 启用 Swap
    mkswap /swapfile
    swapon /swapfile
    # 4. 写入开机自启
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    # 5. 优化系统策略 (优先使用物理内存)
    sysctl vm.swappiness=10
    echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
    echo "✅ Swap 创建成功！"
fi

free -h
echo "------------------------------------------------"


echo "正在安装/更新 Docker..."
curl -fsSL https://get.docker.com | bash

echo "正在启动挂机容器..."

docker rm -f tm 2>/dev/null
docker run -d --restart=always --name tm traffmonetizer/cli_v2 start accept --token cuMj2hyH/bsiJMgQk6wGx8RL4y7b/vtAKF2LxDKtSME=

docker rm -f repocket 2>/dev/null
docker run --name repocket -e RP_EMAIL=cn0514@gmail.com -e RP_API_KEY=492c057e-315c-47f5-96af-8c5768a54d55 -d --restart=always repocket/repocket

docker rm -f earnfm-client 2>/dev/null
docker rmi earnfm/earnfm-client:latest 2>/dev/null
docker run -d --restart=always -e EARNFM_TOKEN="142e1804-f52a-47ac-84ef-87643e13154a" --name earnfm-client earnfm/earnfm-client:latest

docker rm -f psclient 2>/dev/null
docker run -d --restart=always -e CID=7Tzp --name psclient packetstream/psclient:latest

docker rm -f watchtower 2>/dev/null
docker run -d --restart=always --name watchtower -e DOCKER_API_VERSION=1.44 -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --include-stopped --revive-stopped --interval 3600

echo "正在安装常用工具..."
apt update
apt install -y cron unzip

systemctl enable cron
systemctl start cron

curl https://get.acme.sh | sh

echo "========================================"
echo "✅ 所有任务执行完毕！"
echo "当前内存状态："
free -h
