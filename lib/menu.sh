#!/bin/bash

# 菜单函数库

# 显示主菜单
show_main_menu() {
    clear
    echo -e "${CYAN}=== Cloudflare SSL 证书管理工具 ===${NC}"
    echo "1. 创建新的 SSL 证书"
    echo "2. 更新现有证书"
    echo "3. 管理 DNS 记录"
    echo "4. 查看证书信息"
    echo "5. 配置自动续期"
    echo "6. 查看操作日志"
    echo "7. 更新脚本"
    echo "8. 退出"
    echo "9. 列出所有二级域名"
    echo
}

# 显示 DNS 管理子菜单
show_dns_menu() {
    clear
    echo -e "${CYAN}=== DNS 记录管理 ===${NC}"
    echo "1. 添加新的 DNS 记录"
    echo "2. 更新现有 DNS 记录"
    echo "3. 删除 DNS 记录"
    echo "4. 查看所有 DNS 记录"
    echo "5. 返回主菜单"
    echo
}

# 显示证书信息子菜单
show_cert_info_menu() {
    clear
    echo -e "${CYAN}=== 证书信息 ===${NC}"
    echo "1. 查看所有证书"
    echo "2. 查看特定证书详情"
    echo "3. 返回主菜单"
    echo
}