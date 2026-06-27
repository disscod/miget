# === 第一阶段：安装依赖（在各自的目标架构下原生运行，不走 QEMU 模拟） ===
FROM node:alpine3.22 AS builder

WORKDIR /tmp

# 安装编译原生模块可能需要的工具（koffi 编译需要）
RUN apk add --no-cache python3 make g++ gcc

COPY package.json ./
RUN npm install --omit=dev

# === 第二阶段：最终运行镜像（极简、干净） ===
FROM node:alpine3.22

WORKDIR /tmp

# 安装项目运行所需的系统底层依赖
RUN apk add --no-cache openssl curl gcompat iproute2 coreutils bash

# 从第一阶段把装好的依赖复制过来
COPY --from=builder /tmp/node_modules ./node_modules
COPY index.js package.json ./

RUN chmod +x index.js

EXPOSE 5000/tcp

CMD ["node", "index.js"]
