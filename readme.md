<div align="center">

# ⬢ OmniAI-Workspace

<br>

<!-- 高级徽章矩阵 (for-the-badge 风格) -->
<img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
<img src="https://img.shields.io/badge/NVIDIA-GPU_Passthrough-76B900?style=for-the-badge&logo=nvidia&logoColor=white" alt="NVIDIA"/>
<img src="https://img.shields.io/badge/IDE-code--server-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white" alt="VSCode"/>
<img src="https://img.shields.io/badge/AI-Claude_%7C_Gemini-D97757?style=for-the-badge&logo=anthropic&logoColor=white" alt="AI"/>

<br>

**OmniAI-Workspace** 是一个专为现代 AI 开发者打造的<br>“用完即走、随启随用、状态永存”的全能型容器化开发环境。

</div>

<br>

告别繁琐的环境配置与依赖冲突，通过 GitHub Actions 云端构建基础系统，结合宿主机数据卷挂载，为你提供一个纯净、强大且极具弹性的云原生开发舱。

---

### ❖ 核心特性 / Features

* **[ ⎈ ] 全端接入**：浏览器端 `code-server` 与原生 `SSH` 端口双轨并行。
* **[ ⌘ ] AI 原生**：预装 Node.js 环境，内置 `@anthropic-ai/claude-code` 与 Google Auth 工具链。
* **[ ▤ ] 终极持久化**：完美映射项目代码、VS Code 插件、Tmux 配置以及 AI 大模型的登录授权态。
* **[ ⬢ ] 算力释放**：无缝对接 Unraid / Linux 宿主机 NVIDIA Container Toolkit，实现物理级显卡透传，完美支持 `faster-whisper` 等本地模型推理。
* **[ ◈ ] 极简轻量**：业务代码与基础系统解耦，通过内部 `.venv` 隔离 Python 依赖，基础镜像永远保持纯净。