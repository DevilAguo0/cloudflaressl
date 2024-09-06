#!/bin/bash

# 通用函数库

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置文件路径
CONFIG_FILE="config/settings.conf"

# 日志文件路径
LOG_FILE="logs/cloudflaressl.log"

# 日志函数
log() {
    local message="$1"
    local color="${2:-$NC}"
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $message${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

# 错误处理函数
error_exit() {
    log "$1" "${RED}"
    echo
    read -p "按回车键返回主菜单..."
}

# 检查 root 权限
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error_exit "请以 root 权限运行此脚本"
    fi
}

# 检查依赖
check_dependencies() {
    local deps=("curl" "jq" "openssl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error_exit "错误：需要 $dep 命令，但它没有安装。请安装后再运行此脚本。"
        fi
    done
}

# 加密函数
encrypt() {
    echo "$1" | openssl enc -aes-256-cbc -a -salt -pass pass:YordYISecretKey
}

# 解密函数
decrypt() {
    echo "$1" | openssl enc -aes-256-cbc -d -a -salt -pass pass:YordYISecretKey
}

# 保存配置
save_config() {
    local encrypted_email=$(encrypt "$CF_Email")
    local encrypted_key=$(encrypt "$CF_Key")
    local encrypted_domain=$(encrypt "$DOMAIN")
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')

    if [ ! -d "$(dirname "$CONFIG_FILE")" ]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"
    fi

    cat > "$CONFIG_FILE" << EOF
# Cloudflare SSL 证书管理工具配置文件
# 警告：请勿直接编辑此文件，所有值都是加密存储的

CF_Email="$encrypted_email"
CF_Key="$encrypted_key"
DOMAIN="$encrypted_domain"
LAST_UPDATE="$current_date"
EOF
    chmod 600 "$CONFIG_FILE"
    log "配置已加密保存" "${GREEN}"
}

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        if [ -z "$CF_Email" ] || [ -z "$CF_Key" ] || [ -z "$DOMAIN" ]; then
            log "配置文件不完整，需要重新设置" "${YELLOW}"
            get_user_input
            save_config
        else
            CF_Email=$(decrypt "$CF_Email")
            CF_Key=$(decrypt "$CF_Key")
            DOMAIN=$(decrypt "$DOMAIN")
            log "配置加载成功，上次更新时间：$LAST_UPDATE" "${GREEN}"
        fi
    else
        log "配置文件不存在，需要初始设置" "${YELLOW}"
        get_user_input
        save_config
    fi
}

# 获取用户输入
get_user_input() {
    read -p "$(echo -e ${YELLOW}"请输入 Cloudflare 邮箱: "${NC})" CF_Email
    [ -z "$CF_Email" ] && error_exit "错误：Cloudflare 邮箱不能为空"

    read -p "$(echo -e ${YELLOW}"请输入 Cloudflare API 密钥: "${NC})" CF_Key
    [ -z "$CF_Key" ] && error_exit "错误：Cloudflare API 密钥不能为空"

    read -p "$(echo -e ${YELLOW}"请输入主域名: "${NC})" DOMAIN
    [ -z "$DOMAIN" ] && error_exit "错误：主域名不能为空"
}

# 更新配置
update_config() {
    log "更新配置信息" "${BLUE}"
    get_user_input
    save_config
    log "配置更新成功" "${GREEN}"
}