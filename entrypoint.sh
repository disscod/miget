#!/bin/sh

# 1. 动态生成 Xray 配置文件（替代原本 Node.js 里的写文件逻辑）
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

# 3. 启动 Cloudflare Tunnel 并放到后台
if [ -n "${ARGO_AUTH}" ]; then
  /app/cloudflared tunnel --no-autoupdate run --token ${ARGO_AUTH} >/dev/null 2>&1 &
fi

# 4. 启动哪吒监控客户端并放到后台
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
  /app/nezha-agent --server ${NEZHA_SERVER} --secret ${NEZHA_KEY} --tls >/dev/null 2>&1 &
fi

# 5. 最后把 Node.js 服务作为前台主进程启动（防止容器退出）
exec node index.js
