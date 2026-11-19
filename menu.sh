#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 本仓库私有模块地址
TOOLBOX_RAW="https://raw.githubusercontent.com/yzhpxd/vps-toolbox/main"
# 外部独立开源项目地址
VSTREAM_RAW="https://raw.githubusercontent.com/yzhpxd/vstream-3xui/main"
TANZ_RAW="https://raw.githubusercontent.com/yzhpxd/tanZ/main/static"

# 填入你的 GitHub Personal Access Token (ghp_xxx) 以拉取私有仓库脚本
GH_TOKEN=""

fetch_and_run() {
  local url="$1"
  local tmp_file="/tmp/ops_task_$(date +%s)_$RANDOM.sh"
  if [ -n "$GH_TOKEN" ] && [[ "$url" == *"/vps-toolbox/"* ]]; then
    curl -fsSL -H "Authorization: token ${GH_TOKEN}" "$url" -o "$tmp_file"
  else
    curl -fsSL "$url" -o "$tmp_file"
  fi

  if [ -s "$tmp_file" ]; then
    bash "$tmp_file"
    rm -f "$tmp_file"
  else
    echo -e "${RED}错误：脚本拉取失败，请检查网络或仓库权限 (${url})${NC}"
    rm -f "$tmp_file"
  fi
}

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}错误：请使用 root 权限运行此脚本 (sudo bash $0)${NC}"
  exit 1
fi

while true; do
  clear
  echo -e "${CYAN}=====================================================${NC}"
  echo -e "${CYAN}          yzhpxd 专属 VPS 运维工具箱 (1级总控)       ${NC}"
  echo -e "${CYAN}=====================================================${NC}"
  echo -e "  ${GREEN}1.${NC} 系统更新 & 安装 Docker + Docker Compose (基础环境)"
  echo -e "  ${GREEN}2.${NC} 部署 Caddy 视频伪装分流 + 3x-ui 节点 (vstream-3xui)"
  echo -e "  ${GREEN}3.${NC} 配置 1G Swap + Docker 挂机容器集群 (流量挂机)"
  echo -e "  ${GREEN}4.${NC} 安装 tanZ 服务器探针监控 (tanZ)"
  echo -e "  ${GREEN}5.${NC} 一键全自动执行 (依次运行 1 -> 2 -> 3 -> 4)"
  echo -e "  ${YELLOW}0.${NC} 退出脚本"
  echo -e "${CYAN}=====================================================${NC}"
  read -p "请输入选项数字 [0-5]: " CHOICE </dev/tty

  case "$CHOICE" in
    1)
      echo -e "\n${CYAN}>>> 正在启动 [1] 系统更新与 Docker 环境部署...${NC}"
      fetch_and_run "${TOOLBOX_RAW}/init.sh"
      read -p "按回车键返回主菜单..." </dev/tty
      ;;
    2)
      echo -e "\n${CYAN}>>> 正在跳转至 vstream-3xui 部署视频分流 + 3x-ui...${NC}"
      fetch_and_run "${VSTREAM_RAW}/install.sh"
      read -p "按回车键返回主菜单..." </dev/tty
      ;;
    3)
      echo -e "\n${CYAN}>>> 正在启动 [3] Swap + Docker 挂机容器部署...${NC}"
      fetch_and_run "${TOOLBOX_RAW}/earn.sh"
      read -p "按回车键返回主菜单..." </dev/tty
      ;;
    4)
      echo -e "\n${CYAN}>>> 正在跳转至 tanZ 安装探针监控...${NC}"
      fetch_and_run "${TANZ_RAW}/install.sh"
      read -p "按回车键返回主菜单..." </dev/tty
      ;;
    5)
      echo -e "\n${CYAN}>>> 正在全自动执行全部模块 (1 -> 2 -> 3 -> 4)...${NC}"
      fetch_and_run "${TOOLBOX_RAW}/init.sh"
      fetch_and_run "${VSTREAM_RAW}/install.sh"
      fetch_and_run "${TOOLBOX_RAW}/earn.sh"
      fetch_and_run "${TANZ_RAW}/install.sh"
      read -p "全部模块执行完毕，按回车键返回主菜单..." </dev/tty
      ;;
    0)
      echo -e "${GREEN}已退出。${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}输入无效，请输入 0 到 5 之间的数字！${NC}"
      sleep 1
      ;;
  esac
done
