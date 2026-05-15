# OmniAI-Workspace 配置与使用指南

本文档介绍基于 `ghcr.io/siveci/omniai-workspace:latest` 镜像的容器部署、目录映射、访问方式及软件持久化配置方案。

## 1. 宿主机环境准备

在启动容器前，需在宿主机建立对应的持久化目录并配置访问权限。该镜像默认使用 `coder` 用户（UID: 1000）。

### 1.1 目录创建
执行以下命令创建符合 XDG 标准的目录结构：

```bash
# 创建配置、本地数据、缓存及 Gemini CLI 专用目录
mkdir -p <HOST_DATA_PATH>/{config,local,cache,gemini-cli}

# 创建配置文件占位符
touch <HOST_DATA_PATH>/{.bash_aliases,.tmux.conf}
```

### 1.2 权限配置
确保宿主机目录可供容器内 UID 1000 用户读写：

```bash
chown -R 1000:1000 <HOST_DATA_PATH>/
```

## 2. 容器部署 (Docker Run)

使用以下命令启动容器。请根据实际网络环境和硬件配置替换占位符。

```bash
docker run -d \
  --name='omniai-workspace' \
  --runtime=nvidia \
  --net='<NETWORK_NAME>' \
  --ip='<CONTAINER_IP>' \
  --restart unless-stopped \
  -e TZ="<YOUR_TIMEZONE>" \
  -e 'PASSWORD'='<YOUR_WEB_UI_PASSWORD>' \
  -e 'SSH_PASSWORD'='<YOUR_SSH_PASSWORD>' \
  -e 'NVIDIA_VISIBLE_DEVICES'='all' \
  -e 'GIT_CONFIG_GLOBAL'='/home/coder/.config/git/config' \
  -v '<HOST_DATA_PATH>/config/':'/home/coder/.config':'rw' \
  -v '<HOST_DATA_PATH>/local/':'/home/coder/.local':'rw' \
  -v '<HOST_DATA_PATH>/cache/':'/home/coder/.cache':'rw' \
  -v '<HOST_DATA_PATH>/gemini-cli/':'/home/coder/.gemini':'rw' \
  -v '<HOST_DATA_PATH>/.bash_aliases':'/home/coder/.bash_aliases':'rw' \
  -v '<HOST_DATA_PATH>/.tmux.conf':'/home/coder/.tmux.conf':'rw' \
  -v '<HOST_WORKSPACE_PATH>/':'/home/coder/workspace':'rw' \
  'ghcr.io/siveci/omniai-workspace:latest'
```

*注：若无 NVIDIA GPU，需移除 `--runtime=nvidia` 及 `NVIDIA_VISIBLE_DEVICES` 参数。*

## 3. 访问方式

### 3.1 Web UI (Code-Server)
- **地址**: `http://<CONTAINER_IP>:8080`
- **身份验证**: 使用环境变量 `PASSWORD` 设置的密码。

### 3.2 SSH 连接
- **命令**: `ssh -p <PORT> coder@<CONTAINER_IP>`
- **端口说明**: 
  - 若使用自定义网络（如示例中的 `--net` 和 `--ip`），SSH 默认端口通常为 `22`。
  - 若使用端口映射（如 `-p <HOST_PORT>:22`），则需使用指定的 `<HOST_PORT>`。
- **身份验证**: 使用环境变量 `SSH_PASSWORD` 设置的密码。

## 4. 软件模块配置与持久化说明

### 4.1 Git & GitHub CLI
- **配置文件**: 通过 `GIT_CONFIG_GLOBAL` 环境变量指向 `~/.config/git/config`。
- **凭据存储**: 存储于 `~/.config/gh/`。
- **初始化步骤**:
  1. 创建配置目录：`mkdir -p ~/.config/git`
  2. 配置用户信息：`git config --global user.name "<NAME>"` 及 `git config --global user.email "<EMAIL>"`
  3. 登录 GitHub：`gh auth login`

### 4.2 VS Code 插件 (以 Gemini Code Assist 为例)
- **持久化路径**: 插件安装于 `~/.local/share/code-server`，授权缓存存储于 `~/.cache`。
- **操作流程**: 在插件市场安装后，通过浏览器完成 OAuth 授权。相关状态将自动保存至映射的宿主机目录。

### 4.3 Claude Code (API 转发)
- **实现方式**: 通过修改 `.bash_aliases` 配置环境变量，实现 API 请求转发。
- **配置示例**:
  ```bash
  export ANTHROPIC_BASE_URL=<YOUR_API_BASE_URL>
  export ANTHROPIC_AUTH_TOKEN="<YOUR_API_KEY>"
  export ANTHROPIC_MODEL=<YOUR_MODEL_NAME>
  ```
- **生效方式**: 编辑保存后，在 VS Code 中启动新终端。

### 4.4 Tmux
- **配置文件**: 映射至宿主机的 `.tmux.conf`。
- **配置示例 (鼠标支持)**:
  ```text
  set -g mouse on
  set -g default-terminal "screen-256color"
  ```

### 4.5 Gemini CLI
- **数据路径**: 独立映射至 `~/.gemini` 目录。
- **授权流程**: 执行 `gemini` 命令并完成浏览器授权。

### 4.6 GPU 算力与 Python 环境
- **驱动验证**: `nvidia-smi`。
- **环境建议**: 为保持系统环境纯净，建议在 `/home/coder/workspace` 下使用 `venv` 创建独立虚拟环境。
- **操作步骤**:
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  pip install <DEPENDENCIES>
  ```

## 5. 容器内主要持久化目录结构

容器默认用户为 `coder` (UID 1000)，主目录为 `/home/coder`。以下为挂载至宿主机的关键目录：

| 容器内路径 | 宿主机映射路径 (示例) | 说明 |
| :--- | :--- | :--- |
| `/home/coder/.config` | `.../config` | 软件配置文件 (Git, gh, code-server settings 等) |
| `/home/coder/.local` | `.../local` | 本地库与应用数据 (VS Code 插件、Python 包等) |
| `/home/coder/.cache` | `.../cache` | 临时缓存与 OAuth 授权令牌 |
| `/home/coder/.gemini` | `.../gemini-cli` | Gemini CLI 专用授权数据与配置 |
| `/home/coder/workspace` | `.../workspace` | 项目源代码与开发工作目录 |
| `/home/coder/.bash_aliases` | `.../.bash_aliases` | Shell 环境变量与别名配置 |
| `/home/coder/.tmux.conf` | `.../.tmux.conf` | Tmux 终端多路复用器配置 |
