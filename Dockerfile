# 基础镜像：官方 code-server 最新版 (Ubuntu)
FROM codercom/code-server:latest

# 切换 root 用户安装系统级组件
USER root

#安装基础依赖、SSH、Tmux、Python基础、FFMPEG、Node.js、locales 和中文字体安装

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server tmux python3-pip python3-venv nodejs npm sudo curl ffmpeg \
    locales fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*

#生成中文语言包
RUN locale-gen zh_CN.UTF-8

#设置系统默认编码环境变量 (极其重要)
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8
#配置 SSH
RUN mkdir -p /var/run/sshd && \
    echo 'coder:coder123' | chpasswd && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#安装Claude CLI & Gemini CLI
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli

# 切回普通开发用户
USER coder
WORKDIR /home/coder/workspace

#核心启动命令：读取环境变量修改密码 -> 启动 SSH -> 使用 exec 启动 code-server 接收系统信号
ENTRYPOINT []
CMD ["/bin/bash", "-c", "export LANG=zh_CN.UTF-8 && echo \"coder:${SSH_PASSWORD:-coder123}\" | sudo chpasswd && sudo service ssh start && exec code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace"]