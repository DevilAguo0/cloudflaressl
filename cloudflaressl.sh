#!/bin/bash

# Cloudflare SSL 证书管理工具
# 主脚本

# 设置脚本所在目录为工作目录
cd "$(dirname "$0")" || exit

# 导入库文件
source lib/common.sh
source lib/menu.sh
source lib/certificate.sh
source lib/dns.sh
source lib/update.sh

# 欢迎语
clear
echo -e "\033[1;33m"
echo "  __   __   ___    ____    ____     __   __  ___  "
echo "  \ \ / /  / _ \  |  _ \  |  _ \    \ \ / / |_ _| "
echo "   \ V /  | | | | | |_) | | | | |    \ V /   | |  "
echo "    | |   | |_| | |  _ <  | |_| |     | |    | |  "
echo "    |_|    \___/  |_| \_\ |____/      |_|   |___| "
echo -e "\033[0m"
echo -e "\033[1;36m欢迎使用 Yord YI 的 Cloudflare SSL 证书管理工具！\033[0m"
echo -e "\033[1;36m这个强大的工具可以帮助您轻松管理 SSL 证书和 DNS 记录。\033[0m"
echo -e "\033[1;36m让我们开始探索无限可能吧！\033[0m"
echo ""

# 检查是否以 root 权限运行
check_root

# 检查依赖
check_dependencies

# 加载配置
load_config

# 主菜单循环
while true; do
    show_main_menu
    read -p "请选择操作 (1-8): " choice
    case $choice in
        1) create_certificate || error_exit "创建证书失败" ;;
        2) renew_certificate || error_exit "更新证书失败" ;;
        3) manage_dns_records || error_exit "管理 DNS 记录失败" ;;
        4) view_certificate_info || error_exit "查看证书信息失败" ;;
        5) configure_auto_renewal || error_exit "配置自动续期失败" ;;
        6) view_logs || error_exit "查看日志失败" ;;
        7) update_script || error_exit "更新脚本失败" ;;
        8) log "退出程序" "${GREEN}"
           exit 0 ;;
        *) log "无效的选择，请重试。" "${RED}" ;;
    esac
    echo
    read -p "按回车键继续..."
done