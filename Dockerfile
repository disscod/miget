# 换成纯 alpine 基础镜像，不再包含沉重的 node 运行环境
FROM alpine:3.19

RUN apk add --no-cache wget ca-certificates unzip

WORKDIR /app

# 下载所需的组件
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip xray && rm xray.zip && chmod +x xray

RUN wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x cloudflared

RUN wget -O nezha.zip https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip && \
    unzip nezha.zip nezha-agent && rm nezha.zip && chmod +x nezha-agent

# 删除了 COPY package.json 和 RUN npm install 逻辑
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# 暴露的端口（如果不需要网页，其实不暴露出端口也行，完全走 Cloudflare 隧道）
EXPOSE 5000

CMD ["./entrypoint.sh"]
