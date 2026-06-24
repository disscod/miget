# 使用官方轻量级 Node.js 镜像作为基础镜像
FROM node:20-alpine

# 安装基础工具（如 wget，用于下载官方组件）
RUN apk add --no-cache wget ca-certificates

# 设置工作目录
WORKDIR /app

# 根据平台架构下载官方正版编译好的二进制文件（以 AMD64 为例）
# 提示：直接从官方或受信源下载，避免使用未知域名的拼接包
RUN wget -O xray https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip xray && \
    rm Xray-linux-64.zip && \
    chmod +x xray

RUN wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x cloudflared

RUN wget -O nezha-agent https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip && \
    unzip nezha-agent_linux_amd64.zip nezha-agent && \
    rm nezha-agent_linux_amd64.zip && \
    chmod +x nezha-agent

# 复制你的 Node.js 项目文件（确保包含 package.json 和 entrypoint.sh）
COPY package*.json ./
RUN npm install --production
COPY . .

# 赋予入口脚本执行权限
RUN chmod +x entrypoint.sh

# 暴露平台所需的端口（通常是 3000）
EXPOSE 3000

# 通过入口脚本同时管理多个进程
CMD ["./entrypoint.sh"]
