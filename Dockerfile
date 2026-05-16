# 基础镜像：官方 code-server 最新版 (Ubuntu)
FROM codercom/code-server:latest

# 切换 root 用户安装系统级组件
USER root

# 1. 安装基础依赖、SSH、Tmux、Python基础、FFMPEG、Node.js、locales、中文字体
# 同时加入 git 和安装 gh cli 所需的软件源工具
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server tmux python3-pip python3-venv nodejs npm sudo curl ffmpeg \
    locales fonts-noto-cjk git gnupg \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 GitHub CLI (gh) 官方仓库源
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install gh -y

# 3. 彻底修复中文环境：取消注释 -> 重新生成 -> 更新系统默认值
RUN sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=zh_CN.UTF-8

# 4. 设置系统默认编码环境变量 (确保容器启动后默认就是中文)
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 5. 配置 SSH
RUN mkdir -p /var/run/sshd && \
    echo 'coder:coder123' | chpasswd && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 6. 安装 Claude CLI & Gemini CLI & DeepSeek TUI
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli deepseek-tui
# 确保 coder 用户对自己的家目录拥有绝对控制权
RUN chown -R coder:coder /home/coder && chmod -R 755 /home/coder
# 切回普通开发用户
USER coder
WORKDIR /home/coder/workspace

# 7. 核心启动命令
ENTRYPOINT []
CMD ["/bin/bash", "-c", "export LANG=zh_CN.UTF-8 && echo \"coder:${SSH_PASSWORD:-coder123}\" | sudo chpasswd && sudo service ssh start && exec code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace"]