# 换用自带标准 glibc 的 slim 镜像，完美兼容 koffi 和底层 .so 库
FROM node:20-slim

WORKDIR /tmp

# 安装运行所需的系统工具（对应之前的 alpine 工具）
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    curl \
    iproute2 \
    coreutils \
    bash \
    && rm -rf /var/lib/apt/lists/*

# 直接把外部已经装好、编译好的依赖和核心代码塞进来
COPY node_modules ./node_modules
COPY index.js package.json ./

RUN chmod +x index.js

EXPOSE 5000/tcp

CMD ["node", "index.js"]
