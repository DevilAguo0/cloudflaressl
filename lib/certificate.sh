#!/bin/bash

# 证书管理函数库

# acme.sh 路径
ACME_SH="/root/.acme.sh/acme.sh"

# 检查并安装 acme.sh
install_acme() {
    if [ ! -f "$ACME_SH" ]; then
        log "正在安装 acme.sh..." "${BLUE}"
        curl https://get.acme.sh | sh -s email="$CF_Email" || error_exit "错误：安装 acme.sh 失败"
        source ~/.bashrc
        log "acme.sh 安装成功" "${GREEN}"
    else
        log "acme.sh 已安装在 $ACME_SH" "${GREEN}"
    fi
    chmod +x "$ACME_SH"
}

# 创建新证书
create_certificate() {
    install_acme
    
    read -p "请输入要为其创建证书的完整域名: " FULL_DOMAIN
    [ -z "$FULL_DOMAIN" ] && error_exit "错误：域名不能为空"

    log "正在为 $FULL_DOMAIN 创建证书..." "${BLUE}"
    "$ACME_SH" --issue --dns dns_cf -d "$FULL_DOMAIN" || error_exit "错误：生成证书失败"

    install_certificate "$FULL_DOMAIN"
    log "证书创建并安装成功！" "${GREEN}"
}

# 安装证书
install_certificate() {
    local domain="$1"
    local cert_dir="/etc/nginx/ssl"
    
    mkdir -p "$cert_dir"
    
    log "正在安装证书..." "${BLUE}"
    "$ACME_SH" --install-cert -d "$domain" \
        --key-file "$cert_dir/$domain.key" \
        --fullchain-file "$cert_dir/$domain.crt" || error_exit "错误：安装证书失败"

    log "证书已安装到 $cert_dir/$domain.key 和 $cert_dir/$domain.crt" "${GREEN}"
}

# 更新证书
renew_certificate() {
    install_acme
    
    log "正在检查并更新所有证书..." "${BLUE}"
    "$ACME_SH" --renew-all || log "警告：某些证书可能未能更新" "${YELLOW}"
    
    log "证书更新过程完成" "${GREEN}"
}

# 查看证书信息
view_certificate_info() {
    local cert_dir="/etc/nginx/ssl"
    
    while true; do
        show_cert_info_menu
        read -p "请选择操作 (1-3): " choice
        case $choice in
            1) list_all_certificates ;;
            2) view_specific_certificate ;;
            3) return ;;
            *) log "无效的选择，请重试。" "${RED}" ;;
        esac
    done
}

# 列出所有证书
list_all_certificates() {
    local cert_dir="/etc/nginx/ssl"
    log "已安装的证书列表：" "${BLUE}"
    ls -1 "$cert_dir"/*.crt | sed 's/.*\///' | sed 's/\.crt$//'
}

# 查看特定证书详情
view_specific_certificate() {
    local cert_dir="/etc/nginx/ssl"
    read -p "请输入要查看的证书域名: " domain
    local cert_file="$cert_dir/$domain.crt"
    
    if [ -f "$cert_file" ]; then
        log "证书 $domain 的详细信息：" "${BLUE}"
        openssl x509 -in "$cert_file" -text -noout
    else
        log "错误：找不到 $domain 的证书文件" "${RED}"
    fi
}

# 配置自动续期
configure_auto_renewal() {
    install_acme
    log "正在配置证书自动续期..." "${BLUE}"
    "$ACME_SH" --upgrade --auto-upgrade || log "警告：配置自动更新失败，请手动检查" "${YELLOW}"
    log "自动续期配置完成" "${GREEN}"
}