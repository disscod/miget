# === 第一阶段：原生架构依赖打包（解决 koffi 跨架构编译报错） ===
FROM node:alpine3.22 AS builder

WORKDIR /tmp

# 安装编译原生模块（如 koffi）所需的标准工具链
RUN apk add --no-cache python3 make g++ gcc

COPY package.json ./
RUN npm install --omit=dev

# === 第二阶段：最终运行镜像 ===
FROM node:alpine3.22

WORKDIR /tmp

# 安装运行所需的底层系统依赖
RUN apk add --no-cache openssl curl gcompat iproute2 coreutils bash

# 仅复制真正需要的依赖和核心业务代码
COPY --from=builder /tmp/node_modules ./node_modules
COPY index.js package.json ./

# 赋予执行权限
RUN chmod +x index.js

EXPOSE 5000/tcp

CMD ["node", "index.js"]
