# Playwright MCP + VNC

AI 和人工共享同一个浏览器，支持手动点击验证码。

## 架构

```
┌─────────────────────────────────────┐
│  nginx (playwright.jjcc.fun)        │
│  ├── /mcp        → :8931 (需认证)   │
│  ├── /websockify → :6080 (VNC WS)   │
│  └── /           → :6080 (noVNC)    │
├─────────────────────────────────────┤
│  playwright-mcp (单容器)            │
│  ├── Xvfb :99      虚拟显示器       │
│  ├── Chrome        浏览器           │
│  ├── x11vnc :5900  VNC 服务         │
│  ├── noVNC :6080   Web VNC          │
│  └── MCP :8931     AI 控制接口      │
└─────────────────────────────────────┘
```

## 访问地址

| 用途 | 地址 |
|------|------|
| MCP 端点 | `https://playwright.jjcc.fun/mcp` (需认证) |
| VNC 界面 | `https://playwright.jjcc.fun/` |
| VNC 密码 | `playwright` |

## MCP 认证

- 用户名：`playwright`
- 密码：`jHDlyp29Ka7Mlz0Pu2aY`

## MCP 客户端配置

### Claude Code

```bash
claude mcp add playwright https://playwright.jjcc.fun/mcp \
  -t http -s user \
  -H "Authorization: Basic cGxheXdyaWdodDpqSERseXAyOUthN01sejBQdTJhWQ=="
```

### Gemini CLI

```bash
gemini mcp add playwright "https://playwright.jjcc.fun/mcp" \
  -t http -s user \
  -H "Authorization: Basic cGxheXdyaWdodDpqSERseXAyOUthN01sejBQdTJhWQ==" \
  --trust
```

### 通用 JSON 配置

```json
{
  "mcpServers": {
    "playwright": {
      "url": "https://playwright.jjcc.fun/mcp",
      "headers": {
        "Authorization": "Basic cGxheXdyaWdodDpqSERseXAyOUthN01sejBQdTJhWQ=="
      }
    }
  }
}
```

## 启动

```bash
cd /data/compose/playwright-mcp && docker compose up -d
```

## 文件结构

```
playwright-mcp/
├── docker-compose.yml
├── .env                 # VNC_PASSWORD
├── build/
│   ├── Dockerfile       # 基于 playwright/mcp 镜像
│   └── entrypoint.sh    # 启动脚本
└── data/                # 持久化数据
```

## 注意事项

- 容器以 root 运行，Chrome 使用 `--no-sandbox` 模式
- Gemini CLI 存在 JSON Schema 兼容性问题，工具调用可能报错
- Claude Code 可正常使用所有 Playwright MCP 工具
