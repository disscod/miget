#!/bin/sh

# 创建一个静态页面
mkdir -p /app/www
echo "<h1>Hello Miget! This is a test.</h1>" > /app/www/index.html

# 启动哪吒监控（如果填了变量就跑，不填就不跑）
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
  /app/nezha-agent --server ${NEZHA_SERVER} --secret ${NEZHA_KEY} --tls &
fi

# 核心：只启动 thttpd 网页服务器对外响应 5000 端口，不启动任何代理和隧道组件
echo "Starting clean web server on port 5000..."
exec thttpd -D -p 5000 -d /app/www -u root
