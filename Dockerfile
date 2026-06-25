FROM alpine:3.19

# 安装 thttpd（超轻量网页服务器，只占几MB内存，极其稳定响应5000端口）
RUN apk add --no-cache wget ca-certificates unzip sed thttpd

WORKDIR /app

# 下载所需的二进制组件
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip xray && rm xray.zip && chmod +x xray

RUN wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x cloudflared

RUN wget -O nezha.zip https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip && \
    unzip nezha.zip nezha-agent && rm nezha.zip && chmod +x nezha-agent

# 创建一个极简的静态网页，用来应对平台的 5000 端口健康检查
RUN mkdir -p /app/www && echo "OK" > /app/www/index.html

COPY entrypoint.sh .
RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

EXPOSE 5000

CMD ["./entrypoint.sh"]
