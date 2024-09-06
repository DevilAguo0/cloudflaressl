#!/bin/bash

# DNS 记录管理函数库

# 管理 DNS 记录
manage_dns_records() {
    while true; do
        show_dns_menu
        read -p "请选择操作 (1-5): " choice
        case $choice in
            1) add_dns_record ;;
            2) update_dns_record ;;
            3) delete_dns_record ;;
            4) view_dns_records ;;
            5) return ;;
            *) log "无效的选择，请重试。" "${RED}" ;;
        esac
    done
}

# 添加 DNS 记录
add_dns_record() {
    echo "添加新的 DNS 记录"
    echo "记录类型说明："
    echo "A: 将域名指向 IPv4 地址"
    echo "AAAA: 将域名指向 IPv6 地址"
    echo "CNAME: 将域名指向另一个域名"
    echo "TXT: 存储文本信息，通常用于验证域名所有权"
    echo "MX: 指定邮件服务器"
    echo

    local subdomain
    local type
    local content

    while true; do
        read -p "请输入二级域名前缀（不包含主域名）: " subdomain
        local full_domain="${subdomain}.${DOMAIN}"
        
        if check_subdomain_exists "$full_domain"; then
            log "警告：二级域名 $full_domain 已存在。请重新输入。" "${YELLOW}"
        else
            break
        fi
    done

    read -p "请输入记录类型 (A, AAAA, CNAME, TXT, MX 等): " type
    read -p "请输入记录内容: " content

    log "正在添加 DNS 记录..." "${BLUE}"
    local response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
         -H "X-Auth-Email: $CF_Email" \
         -H "X-Auth-Key: $CF_Key" \
         -H "Content-Type: application/json" \
         --data "{\"type\":\"$type\",\"name\":\"$full_domain\",\"content\":\"$content\",\"ttl\":1,\"proxied\":false}")

    if echo "$response" | jq -e '.success' &>/dev/null; then
        log "DNS 记录添加成功" "${GREEN}"
    else
        log "DNS 记录添加失败。错误信息：$(echo "$response" | jq '.errors')" "${RED}"
    fi
}

# 更新 DNS 记录
update_dns_record() {
    echo "更新现有 DNS 记录"
    echo "请注意：更新记录时，只能修改内容，不能更改记录类型"
    echo

    local subdomain
    local type
    local content
    local record_id

    read -p "请输入要更新的二级域名前缀: " subdomain
    local full_domain="${subdomain}.${DOMAIN}"
    read -p "请输入记录类型 (A, AAAA, CNAME, TXT, MX 等): " type
    read -p "请输入新的记录内容: " content

    record_id=$(get_record_id "$full_domain")

    if [ -z "$record_id" ]; then
        log "未找到指定的 DNS 记录" "${RED}"
        return
    fi

    log "正在更新 DNS 记录..." "${BLUE}"
    local response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id" \
         -H "X-Auth-Email: $CF_Email" \
         -H "X-Auth-Key: $CF_Key" \
         -H "Content-Type: application/json" \
         --data "{\"type\":\"$type\",\"name\":\"$full_domain\",\"content\":\"$content\",\"ttl\":1,\"proxied\":false}")

    if echo "$response" | jq -e '.success' &>/dev/null; then
        log "DNS 记录更新成功" "${GREEN}"
    else
        log "DNS 记录更新失败。错误信息：$(echo "$response" | jq '.errors')" "${RED}"
    fi
}

# 删除 DNS 记录
delete_dns_record() {
    local subdomain
    local record_id

    read -p "请输入要删除的二级域名前缀: " subdomain
    local full_domain="${subdomain}.${DOMAIN}"

    record_id=$(get_record_id "$full_domain")

    if [ -z "$record_id" ]; then
        log "未找到指定的 DNS 记录" "${RED}"
        return
    fi

    log "正在删除 DNS 记录..." "${BLUE}"
    local response=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id" \
         -H "X-Auth-Email: $CF_Email" \
         -H "X-Auth-Key: $CF_Key" \
         -H "Content-Type: application/json")

    if echo "$response" | jq -e '.success' &>/dev/null; then
        log "DNS 记录删除成功" "${GREEN}"
    else
        log "DNS 记录删除失败。错误信息：$(echo "$response" | jq '.errors')" "${RED}"
    fi
}

# 查看 DNS 记录
view_dns_records() {
    log "正在获取 DNS 记录..." "${BLUE}"
    local response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
         -H "X-Auth-Email: $CF_Email" \
         -H "X-Auth-Key: $CF_Key" \
         -H "Content-Type: application/json")

    if echo "$response" | jq -e '.success' &>/dev/null; then
        echo "$response" | jq -r '.result[] | "\(.type) \(.name) \(.content)"'
    else
        log "获取 DNS 记录失败。错误信息：$(echo "$response" | jq '.errors')" "${RED}"
    fi
    echo
    read -p "按回车键返回 DNS 管理菜单..."
}

# 获取记录 ID
get_record_id() {
    local full_domain="$1"
    local response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$full_domain" \
         -H "X-Auth-Email: $CF_Email" \
         -H "X-Auth-Key: $CF_Key" \
         -H "Content-Type: application/json")

    echo "$response" | jq -r '.result[0].id'
}

# 检查子域名是否存在
check_subdomain_exists() {
    local full_domain="$1"
    local response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$full_domain" \
         -H "X-Auth-Email: $CF_Email" \
         -H "X-Auth-Key: $CF_Key" \
         -H "Content-Type: application/json")

    if echo "$response" | jq -e '.result[0]' &>/dev/null; then
        return 0  # 子域名存在
    else
        return 1  # 子域名不存在
    fi
}