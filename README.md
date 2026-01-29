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
│  ├── Xvnc :99     虚拟显示器(TigerVNC)│
│  ├── openbox      窗口管理器        │
│  ├── Chrome       浏览器            │
│  ├── fcitx        中文输入法        │
│  ├── noVNC :6080  Web VNC          │
│  └── MCP :8931    AI 控制接口      │
└─────────────────────────────────────┘
```

## 功能特性

- **VNC 分辨率自适应**：使用 TigerVNC (Xvnc) 支持动态分辨率调整，自动适应浏览器窗口大小
- **剪贴板自动同步**：基于 noVNC 1.6.0 源码修改，支持自动剪贴板同步
  - 页面获得焦点时自动读取本地剪贴板
  - 按 `Ctrl+V` / `Cmd+V` 时自动粘贴本地剪贴板内容到 VNC
  - 首次使用需授权浏览器剪贴板权限
- **中文输入法**：fcitx + Google Pinyin，`Ctrl + Space` 切换输入法
- **窗口管理器**：openbox 使 Chrome 能正确响应最大化/调整窗口
- **代理扩展**：预装 ZeroOmega (SwitchyOmega V3) 代理管理扩展
- **数据持久化**：Chrome profile 和扩展数据持久化到 `./data/` 目录

## 环境变量

在 `.env` 文件中配置：

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `VNC_PASSWORD` | VNC 访问密码 | `playwright` |
| `MCP_PASSWORD` | MCP 端点认证密码（nginx 配置） | - |

## 访问地址

| 用途 | 地址 |
|------|------|
| MCP 端点 | `https://playwright.jjcc.fun/mcp` (需认证) |
| VNC 界面 | `https://playwright.jjcc.fun/` |
| VNC 密码 | 见 `.env` 中的 `VNC_PASSWORD` |

## MCP 认证

MCP 端点通过 nginx 进行 Basic Auth 认证，密码在 nginx 配置中设置。

## MCP 客户端配置

### Claude Code

```bash
claude mcp add playwright https://playwright.jjcc.fun/mcp \
  -t http -s user \
  -H "Authorization: Basic <base64编码的密码>"
```

### Gemini CLI

```bash
gemini mcp add playwright "https://playwright.jjcc.fun/mcp" \
  -t http -s user \
  -H "Authorization: Basic <base64编码的密码>" \
  --trust
```

### 通用 JSON 配置

```json
{
  "mcpServers": {
    "playwright": {
      "url": "https://playwright.jjcc.fun/mcp",
      "headers": {
        "Authorization": "Basic <base64编码的密码>"
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
├── .env                 # VNC_PASSWORD, MCP_PASSWORD
├── build/
│   ├── Dockerfile       # 基于 playwright/mcp 镜像
│   ├── entrypoint.sh    # 启动脚本
│   ├── novnc-src/       # noVNC 1.6.0 源码（含自动剪贴板修改）
│   └── patches/         # 配置补丁
│       └── fonts.conf   # 中文字体配置
└── data/                # 持久化数据
    ├── chrome-profile/  # Chrome 用户数据
    └── extensions/      # Chrome 扩展
        └── switchyomega/  # ZeroOmega 扩展
```

## 代理扩展

容器预装了 [ZeroOmega](https://github.com/zero-peak/ZeroOmega) (Proxy SwitchyOmega 3)，这是 SwitchyOmega 的 Manifest V3 版本。

如果扩展没有自动加载，需要手动启用：

1. 在 VNC 中打开 Chrome，访问 `chrome://extensions`
2. 开启右上角的「开发者模式」
3. 点击「加载已解压的扩展程序」
4. 选择目录 `/data/extensions/switchyomega`

## 剪贴板使用

剪贴板支持**自动同步**，无需手动操作：

1. **从本地粘贴到 VNC**：直接在 VNC 中按 `Ctrl+V`，本地剪贴板内容会自动发送
2. **焦点触发**：切换到 VNC 页面时自动同步剪贴板
3. **首次使用**：浏览器会请求剪贴板权限，请点击"允许"

> 备用方式：如果自动同步失败，可使用 noVNC 左侧的剪贴板面板手动操作

## 注意事项

- 容器以 root 运行，Chrome 使用 `--no-sandbox` 模式
- Gemini CLI 存在 JSON Schema 兼容性问题，工具调用可能报错
- Claude Code 可正常使用所有 Playwright MCP 工具
- Chrome profile 持久化，`docker compose down && up` 不会丢失数据
