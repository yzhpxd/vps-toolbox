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
echo -e "${CYAN}      [2级模块] 系统更新 & Docker / Compose 安装      ${NC}"
echo -e "${CYAN}=====================================================${NC}"

echo -e "\n${YELLOW}[1/3] 正在更新系统软件包并安装基础依赖...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt update -y && apt upgrade -y
apt install -y curl wget sudo socat unzip

echo -e "\n${YELLOW}[2/3] 正在检查并安装 Docker...${NC}"
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
  echo -e "${GREEN}Docker 安装并启动成功！${NC}"
else
  echo -e "${GREEN}检测到 Docker 已安装 ($(docker -v))，跳过重复安装。${NC}"
fi

echo -e "\n${YELLOW}[3/3] 正在安装最新版 Docker Compose...${NC}"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}基础环境部署完成！当前版本信息：${NC}"
echo -e "Docker:         ${CYAN}$(docker -v)${NC}"
echo -e "Docker Compose: ${CYAN}$(docker-compose -v)${NC}"
echo -e "${GREEN}=====================================================${NC}"
