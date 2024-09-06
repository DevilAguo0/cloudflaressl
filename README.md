# Cloudflare SSL 证书管理工具

## 概述

Cloudflare SSL 证书管理工具是一个强大的 Bash 脚本集，用于自动化管理 Cloudflare DNS 和 SSL 证书。这个工具可以帮助您轻松创建、更新和管理 SSL 证书，以及处理 Cloudflare DNS 记录。

## 主要功能

- 自动创建和更新 SSL 证书
- 管理 Cloudflare DNS 记录
- 交互式菜单界面
- 配置信息加密存储
- 自动检查和续期证书
- 详细的日志记录
- 脚本自动更新

## 系统要求

- 基于 Debian/Ubuntu 的 Linux 系统
- root 权限
- curl
- jq
- openssl

## 安装

1. 克隆仓库：
   ```
   git clone https://github.com/yourusername/cloudflare-ssl.git
   ```

2. 进入项目目录：
   ```
   cd cloudflare-ssl
   ```

3. 给主脚本添加执行权限：
   ```
   chmod +x cloudflaressl.sh
   ```

## 使用方法

1. 运行主脚本：
   ```
   ./cloudflaressl.sh
   ```

2. 首次运行时，您需要输入 Cloudflare 账户信息和域名。这些信息将被加密存储，以后运行时无需重新输入。

3. 使用交互式菜单选择所需的操作。

## 功能列表

- 创建新的 SSL 证书
- 更新现有证书
- 管理 DNS 记录（添加、更新、删除）
- 查看证书信息
- 配置自动续期
- 查看操作日志
- 更新脚本

## 配置文件

配置文件位于 `config/settings.conf`。该文件包含加密的 Cloudflare 账户信息和其他设置。请不要直接编辑此文件。

## 日志

操作日志保存在 `logs/cloudflaressl.log` 文件中。如果遇到问题，请查看此日志文件以获取详细信息。

## 注意事项

- 请确保您的服务器时间是准确的，这对于证书的创建和更新非常重要。
- 定期备份您的证书和配置文件。
- 如果更改了 Cloudflare 账户信息，请重新运行脚本并更新配置。

## 故障排除

如果遇到问题：

1. 检查日志文件 `logs/cloudflaressl.log`。
2. 确保您有最新版本的脚本。
3. 验证您的 Cloudflare API 凭证是否正确。
4. 检查您的网络连接。

如果问题仍然存在，请提交一个 issue，并附上日志文件的相关部分（请确保删除所有敏感信息）。

## 贡献

欢迎贡献！请 fork 本仓库并提交 pull request。

## 许可证

本项目采用 MIT 许可证。详情请见 [LICENSE](LICENSE) 文件。

## 联系方式

如有任何问题或建议，请通过 [issues](https://github.com/yourusername/cloudflare-ssl/issues) 联系我们。
