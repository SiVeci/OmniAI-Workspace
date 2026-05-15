# 基础镜像：官方 code-server 最新版 (Ubuntu)
FROM codercom/code-server:latest

# 切换 root 用户安装系统级组件
USER root

# 1. 安装基础依赖、SSH、Tmux、Python基础、FFMPEG 和 Node.js
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server tmux python3-pip python3-venv nodejs npm sudo curl ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 2. 配置 SSH
RUN mkdir -p /var/run/sshd && \
    echo 'coder:coder123' | chpasswd && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 3. 安装Claude CLI & Gemini CLI
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli

# 切回普通开发用户
USER coder
WORKDIR /home/coder/workspace

# 4. 核心启动命令：读取环境变量修改密码 -> 启动 SSH -> 使用 exec 启动 code-server 接收系统信号
ENTRYPOINT []
CMD ["/bin/bash", "-c", "echo \"coder:${SSH_PASSWORD:-coder123}\" | sudo chpasswd && sudo service ssh start && exec code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace"]