# k3s 上线闭环：滚动发布与回滚

这个项目完成了一个端到端的上线闭环：镜像 v1/v2 构建发布 → k3s 部署（Deployment/Service）→ Caddy 作为公网入口；并验证滚动更新与回滚路径可用，发布记录可追溯（change-cause）。

在线地址：
- 首页：http://8.138.112.171.nip.io/
- Demo：http://8.138.112.171.nip.io/demo

## 技术栈
- k3s / Kubernetes：Deployment、Service(NodePort)
- 镜像仓库：ACR（v1/v2）
- 入口层：Caddy（:80；/ 为作品页；/demo 反代到 NodePort）
- 基础安全：UFW 收口端口；禁用 root 远程登录，仅允许 dev 登录

## 我在项目里做了什么
- 镜像版本管理：发布 v1/v2 镜像，用于验证发布与回滚链路
- 集群编排：在 k3s 部署 Deployment（2 副本）+ Service(NodePort:30080)
- 公网入口：Caddy 监听 80 对外提供访问；/demo 反代到 127.0.0.1:30080
- 发布控制：kubectl set image 触发滚动更新；rollout status/history 跟踪结果
- 可观测与核验：页面展示运行状态（Deployment/Pods/发布记录/demo 输出），便于核对真实运行

## 架构（访问链路）
Browser → Caddy(:80) → NodePort(127.0.0.1:30080) → k3s Service → Pods(Deployment)

## 常用验证命令
```bash
kubectl -n demo get deploy web -o wide
kubectl -n demo get pods -o wide
kubectl -n demo rollout history deploy/web

# v1/v2 切换
kubectl -n demo set image deploy/web nginx=<YOUR_IMAGE>:v2
kubectl -n demo rollout status deploy/web
```

## 仓库结构
- `k8s/`：Deployment / Service（NodePort）清单
- `caddy/`：Caddyfile（80 入口，/ 为作品页，/demo 反代）
- `site/`：静态作品页（首页）
- `scripts/`：一键导出运行快照（可复现输出）

## 一键导出运行快照（用于作品页展示/留档）
```bash
bash scripts/collect-snapshots.sh
ls -la site/evidence/
```
