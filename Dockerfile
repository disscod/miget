FROM node:20-alpine

# 安装基础工具，包含必不可少的解压工具 unzip
RUN apk add --no-cache wget ca-certificates unzip

WORKDIR /app

# 下载、解压并赋予可执行权限
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip xray && rm xray.zip && chmod +x xray

RUN wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x cloudflared

RUN wget -O nezha.zip https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip && \
    unzip nezha.zip nezha-agent && rm nezha.zip && chmod +x nezha-agent

# 复制 Node.js 项目配置文件
COPY package*.json ./
RUN npm install --production
COPY . .

# 确保启动脚本有执行权限
RUN chmod +x entrypoint.sh

EXPOSE 3000

CMD ["./entrypoint.sh"]
