#!/usr/bin/env node

const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = process.env.PORT || 3000;
const SUB_PATH = process.env.SUB_PATH || 'sub';
const UUID = process.env.UUID;
const ARGO_DOMAIN = process.env.ARGO_DOMAIN || 'your-argo-domain.com';

// 纯粹的 Web 路由服务
const server = http.createServer((req, res) => {
  const urlPath = req.url.split('?')[0];

  // 节点订阅路由
  if (urlPath === `/${SUB_PATH}`) {
    if (!UUID) {
      res.writeHead(500);
      return res.end("UUID empty");
    }
    
    // 原生凭借节点信息，不再需要依赖复杂的后台文件读取
    const vlessURL = `vless://${UUID}@${ARGO_DOMAIN}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&fp=chrome&type=ws&host=${ARGO_DOMAIN}&path=%2Fvless-argo#Docker-Node`;
    const base64Content = Buffer.from(vlessURL).toString('base64');

    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    return res.end(base64Content + '\n');
  }

  // 根路由响应标准网页
  if (urlPath === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    return res.end("<h1>Application Service</h1><p>Status: Running</p>");
  }

  res.writeHead(404);
  res.end('Not Found');
});

server.listen(PORT, () => console.log(`HTTP server running on port:${PORT}`));
