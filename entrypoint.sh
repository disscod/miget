#!/bin/sh

# 1. 动态生成 Xray 配置文件
cat <<EOF > /app/config.json
{
  "log": { "loglevel": "none" },
  "inbounds": [
    { 
      "port": ${ARGO_PORT:-8001}, 
      "protocol": "vless", 
      "settings": { "clients": [{ "id": "${UUID}" }], "decryption": "none" },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/vless-argo" } }
    }
  ],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF

# 2. 启动 Xray 并放到后台
/app/xray -c /app/config.json >/dev/null 2>&1 &

# 3. 启动哪吒监控客户端（如果不需要哪吒，可以把这三行删掉进一步省内存）
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
  echo "Starting Nezha Agent..."
  /app/nezha-agent --server ${NEZHA_SERVER} --secret ${NEZHA_KEY} --tls >/dev/null 2>&1 &
fi

# 4. 修改这里：不再运行 Node.js。直接在前台启动 cloudflared
# 这样 cloudflared 会常驻前台支撑容器，同时省去了 Node.js 虚拟机的巨大内存开销
if [ -n "${ARGO_TOKEN}" ]; then
  echo "Starting Cloudflare Tunnel as main process..."
  exec /app/cloudflared tunnel --no-autoupdate run --token ${ARGO_TOKEN}
else
  echo "ERROR: ARGO_TOKEN is required!"
  exit 1
fi
