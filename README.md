# 🚀 k3s DevOps 闭环：CI/CD、滚动发布与自动化观测

本项目实现了一个**端到端的 DevOps 自动化上线闭环**。从底层的容器编排，到顶层的代码推送即部署（Push-to-Deploy），全面覆盖了现代化云原生应用的交付全流程。

重点验证并展示了：**CI/CD 自动化流水线**、**K8s 滚动更新与秒级回滚**、以及**运行状态的自动化快照留痕**。

## 🌐 在线演示 (Live Demo)
- **项目状态主页**：[http://8.138.112.171.nip.io/](http://8.138.112.171.nip.io/) （实时拉取底层集群运行快照）
- **业务演示接口**：[http://8.138.112.171.nip.io/demo](http://8.138.112.171.nip.io/demo) （反向代理至底层 Pod）

---

## 🛠️ 核心技术栈
- **CI/CD 流水线**：GitHub Actions, Self-hosted Runner
- **容器与编排**：Docker, k3s (Kubernetes 轻量级发行版), Deployment, Service (NodePort)
- **网关与反向代理**：Caddy (自动 HTTPS 预留，当前暴露 :80)
- **自动化运维**：Shell Script (状态自动化抓取)
- **系统与安全**：Ubuntu 22.04, UFW 防火墙加固, SSH 密钥认证及普通用户权限隔离

---

## 💡 架构设计与访问链路

项目采用了**网关层与服务层解耦**的设计，便于独立排障与水平扩展：

`Browser` 访问公网 80 端口 
  ➔ `Caddy` (反向代理网关) 
  ➔ `127.0.0.1:30080` (K8s NodePort) 
  ➔ `k3s Service` (demo/web-svc) 
  ➔ `Pods` (Deployment, 跨双副本负载均衡)

---

## 🎯 我在项目中解决的核心痛点（核心亮点）

### 1. 彻底告别手动部署 (CI/CD 落地)
- 引入 **GitHub Actions** 并配置宿主机级别的 **Self-hosted Runner**。
- 实现了 `git push` 后触发流水线，毫秒级将最新静态资源与运维脚本下发至服务器本地，完成免密、零人工干预的自动化部署。

### 2. 业务零中断的滚动更新 (Rolling Update)
- 配置 K8s Deployment 的 `maxSurge` 和 `maxUnavailable` 策略。
- 在升级 `v1` -> `v2` 镜像时，实现新旧 Pod 流量平滑交接；并具备一键回滚 (`rollout undo`) 能力，保障生产环境高可用。

### 3. 可验证的自动化观测 (Observability)
- 编写 Shell 脚本，由 CI 流水线触发，自动提取 `kubectl get pods`、`rollout history` 等核心运行指标。
- 将后端运行的“黑盒”状态转换为可读文本，直接渲染在前端页面，实现**发布过程可追溯，运行状态可自证**。

---

## 📂 仓库结构

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml        # CI/CD 核心引擎：定义自动化构建与部署流水线
├── k8s/
│   ├── deploy.yaml           # Kubernetes Deployment 声明 (管理 Pod 副本与镜像策略)
│   └── service.yaml          # Kubernetes Service 声明 (暴露 NodePort 30080)
├── caddy/
│   └── Caddyfile             # Web 服务器配置 (处理 / 与 /demo 的流量分发)
├── scripts/
│   └── collect-snapshots.sh  # 自动化运维脚本 (抓取集群快照并输出给前端)
└── site/
    └── index.html            # 演示主页源码 (数据动态读取)
