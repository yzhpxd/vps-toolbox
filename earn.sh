#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}错误：请使用 root 权限运行此脚本！${NC}"
  exit 1
fi

echo -e "${CYAN}=====================================================${NC}"
echo -e "${CYAN}   [2级模块] Swap 1G + Docker + 挂机容器一键部署     ${NC}"
echo -e "${CYAN}=====================================================${NC}"

echo -e "\n${YELLOW}[1/4] 正在检查 Swap 设置...${NC}"
if [ -f /swapfile ]; then
    echo "✅ /swapfile 已存在，跳过创建步骤。"
else
    echo "⚠️ 未检测到 Swap，正在创建 1GB 虚拟内存..."
    dd if=/dev/zero of=/swapfile bs=1M count=1024
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    sysctl vm.swappiness=10
    echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
    echo "✅ Swap 创建成功！"
fi

free -h
echo "------------------------------------------------"

echo -e "\n${YELLOW}[2/4] 正在安装/更新 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | bash
    systemctl enable --now docker
else
    echo "✅ 检测到 Docker 已安装 ($(docker -v))，跳过重装。"
fi

echo -e "\n${YELLOW}[3/4] 正在启动挂机容器与 Watchtower...${NC}"

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

echo -e "\n${YELLOW}[4/4] 正在安装常用工具与 acme.sh...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y cron unzip curl socat

systemctl enable cron
systemctl start cron

if [ ! -d "$HOME/.acme.sh" ]; then
    curl https://get.acme.sh | sh
else
    echo "✅ acme.sh 已安装，跳过。"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ 所有任务执行完毕！${NC}"
echo "当前内存状态："
free -h
echo -e "${GREEN}========================================${NC}"
