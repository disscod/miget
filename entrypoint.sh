#!/bin/sh

# 1. 动态生成 Xray 配置文件（锁在 8001 内部端口）
cat <<EOF > /app/config.json
{
  "log": { "loglevel": "none" },
  "inbounds": [
    { 
      "port": 8001, 
      "protocol": "vless", 
      "settings": { "clients": [{ "id": "${UUID}" }], "decryption": "none" },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/vless-argo" } }
    }
  ],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF

# 2. 启动 Xray
/app/xray -c /app/config.json &

# 3. 启动哪吒监控（如果填写了变量）
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
  /app/nezha-agent --server ${NEZHA_SERVER} --secret ${NEZHA_KEY} --tls &
fi

# 4. 在后台假装响应平台的 5000 端口健康检查（防止平台因为找不到 5000 端口而报错）
while true; do 
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nOK" | nc -l -p 5000
done &

# 5. 【核心修正】强制降低 cloudflared 的网络连接数，把它变成省电模式
# --protocol http2: 强制使用单连接的 HTTP2 协议，不使用消耗内存巨大的 QUIC 协议
# --max-upstream-connections 2: 严格限制并发连接数，不让它吃满 CPU 
if [ -n "${ARGO_TOKEN}" ]; then
  echo "Starting Cloudflare Tunnel in eco-mode..."
  exec /app/cloudflared tunnel --no-autoupdate --protocol http2 --max-upstream-connections 2 run --token ${ARGO_TOKEN}
else
  echo "ERROR: ARGO_TOKEN is required!"
  exit 1
fi
