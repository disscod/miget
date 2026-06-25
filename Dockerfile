# 第一阶段：从 Cloudflare 官方极致压缩的镜像里，把已经编译、优化好的 cloudflared 提取出来
FROM cloudflare/cloudflared:latest AS cloudflared-source

# 第二阶段：构建我们的极简轻量运行环境
FROM alpine:3.19

RUN apk add --no-cache wget ca-certificates unzip sed thttpd

WORKDIR /app

# 1. 复制官方压榨到极致的 cloudflared 二进制文件（体积会小非常多）
COPY --from=cloudflared-source /usr/local/bin/cloudflared /app/cloudflared
RUN chmod +x /app/cloudflared

# 2. 仅下载必要的 Xray（把不必要的组件或多余文件全清空）
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip xray && rm xray.zip && chmod +x xray

# 3. 仅下载哪吒监控
RUN wget -O nezha.zip https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip && \
    unzip nezha.zip nezha-agent && rm nezha.zip && chmod +x nezha-agent

# 4. 创建静态网页应对健康检查
RUN mkdir -p /app/www && echo "OK" > /app/www/index.html

COPY entrypoint.sh .
RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

EXPOSE 5000

CMD ["./entrypoint.sh"]
