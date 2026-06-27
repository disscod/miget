FROM node:alpine3.22

WORKDIR /tmp

# 1. 安装项目运行所需的系统级基础依赖（不再包含 apk upgrade 减少干扰）
RUN apk add --no-cache openssl curl gcompat iproute2 coreutils bash

# 2. 直接把宿主机上已经装好的 node_modules 和代码一并复制进去
COPY node_modules ./node_modules
COPY index.js package.json ./

# 如果你的项目里真的不需要 index.html，下面这行可以不写（根据代码来看确实没用到）
# COPY index.html ./ 

# 3. 赋予执行权限
RUN chmod +x index.js

EXPOSE 5000/tcp

CMD ["node", "index.js"]
