#!/bin/sh

# 1. 动态生成 Xray 配置文件（锁定 8001 内部端口）
cat <<EOF > /app/config.json
{
  "log": { "loglevel": "none" },
  "inbounds": [
    { 
      "port": 8001, 
      "protocol": "vless", 
      "settings": { "clients": [{ "id": "${UUID:-019efc8b-d99a-77f0-968a-f6839421c79f}" }], "decryption": "none" },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/vless-argo" } }
    }
  ],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF

# 2. 启动 Xray
/app/xray -c /app/config.json &

# 3. 启动哪吒监控（如果填了变量）
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
  /app/nezha-agent --server ${NEZHA_SERVER} --secret ${NEZHA_KEY} --tls &
fi

# 4. 启动 Cloudflare 隧道（即使没变量也在后台挂着，绝不闪退）
if [ -n "${ARGO_TOKEN}" ]; then
  /app/cloudflared tunnel --no-autoupdate --protocol http2 --max-upstream-connections 2 run --token ${ARGO_TOKEN} &
else
  echo "WARNING: ARGO_TOKEN is missing, tunnel won't start."
fi

# 5. 【核心保底主进程】在前台启动 thttpd 监听 5000 端口
# 它是专业的、极其坚固的网页服务器，不管平台怎么高频探测，都会秒回 200 OK，且内存开销几乎为 0
echo "Starting thttpd on port 5000..."
exec thttpd -D -p 5000 -d /app/www -u root
