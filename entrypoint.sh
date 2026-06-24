#!/bin/sh

# 1. 动态生成 Xray 配置文件（直接监听平台强制要求的 5000 端口）
cat <<EOF > /app/config.json
{
  "log": { "loglevel": "none" },
  "inbounds": [
    { 
      "port": 5000, 
      "protocol": "vless", 
      "settings": { "clients": [{ "id": "${UUID}" }], "decryption": "none" },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/vless-argo" } }
    }
  ],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF

# 2. 后台启动 Xray
/app/xray -c /app/config.json &

# 3. 后台启动哪吒监控（如果填写了对应环境变量）
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
  /app/nezha-agent --server ${NEZHA_SERVER} --secret ${NEZHA_KEY} --tls &
fi

# 4. 前台启动 Cloudflare 隧道（支撑整个容器常驻不退出）
if [ -n "${ARGO_TOKEN}" ]; then
  echo "Starting Cloudflare Tunnel as main process..."
  exec /app/cloudflared tunnel --no-autoupdate run --token ${ARGO_TOKEN}
else
  echo "ERROR: ARGO_TOKEN is required!"
  exit 1
fi
