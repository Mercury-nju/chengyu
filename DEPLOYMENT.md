# Vercel 部署指南

## 快速部署步骤

### 1. 准备 GitHub 仓库（推荐）

```bash
cd website
git init
git add .
git commit -m "Initial commit: 澄域官网"
git branch -M main
git remote add origin https://github.com/你的用户名/chengyu-website.git
git push -u origin main
```

### 2. 部署到 Vercel

#### 方法 A：通过 Vercel 网站（最简单）

1. 访问 https://vercel.com
2. 使用 GitHub 账号登录
3. 点击 "Add New" → "Project"
4. 选择你的 GitHub 仓库 `chengyu-website`
5. 配置：
   - Framework Preset: Other
   - Root Directory: `./`（保持默认）
   - Build Command: 留空
   - Output Directory: `./`（保持默认）
6. 点击 "Deploy"
7. 等待部署完成（约 1-2 分钟）

#### 方法 B：使用 Vercel CLI

```bash
# 安装 Vercel CLI
npm install -g vercel

# 登录
vercel login

# 部署
cd website
vercel

# 生产环境部署
vercel --prod
```

### 3. 绑定自定义域名

部署完成后：

1. 在 Vercel 项目页面，点击 "Settings" → "Domains"
2. 添加域名：`chengyu.space`
3. Vercel 会提供 DNS 配置信息

#### 在域名注册商处配置 DNS

添加以下记录：

**A 记录：**
```
类型: A
名称: @
值: 76.76.21.21
```

**CNAME 记录（推荐）：**
```
类型: CNAME
名称: @
值: cname.vercel-dns.com
```

或者使用 Vercel 的 Nameservers（最简单）：
```
ns1.vercel-dns.com
ns2.vercel-dns.com
```

4. 等待 DNS 生效（可能需要几分钟到几小时）
5. 访问 `https://chengyu.space` 测试

### 4. 配置 HTTPS

Vercel 会自动为你的域名配置 SSL 证书（Let's Encrypt），无需手动操作。

### 5. 验证部署

访问以下 URL 确认：
- https://chengyu.space
- https://chengyu.space/privacy.html
- https://chengyu.space/terms.html

## 文件结构

```
website/
├── index.html          # 首页
├── privacy.html        # 隐私政策
├── terms.html          # 用户协议
├── style.css           # 样式文件
├── logo.jpeg           # Logo
├── 功能介绍/           # 截图文件夹
│   ├── 冥想.png
│   ├── 觉察.png
│   └── 具象.png
├── vercel.json         # Vercel 配置
└── DEPLOYMENT.md       # 本文档
```

## 更新网站

### 通过 GitHub（推荐）

```bash
# 修改文件后
git add .
git commit -m "更新内容"
git push

# Vercel 会自动重新部署
```

### 通过 Vercel CLI

```bash
cd website
vercel --prod
```

## 常见问题

### Q1: 部署后看不到图片？
**A:** 确保所有图片文件都已提交到 Git 仓库。

### Q2: 域名配置后无法访问？
**A:** 
- 检查 DNS 配置是否正确
- 等待 DNS 传播（最多 48 小时，通常几分钟）
- 使用 https://dnschecker.org 检查 DNS 状态

### Q3: 如何回滚到之前的版本？
**A:** 在 Vercel 项目页面的 "Deployments" 中，找到之前的部署，点击 "Promote to Production"。

### Q4: 如何查看访问统计？
**A:** Vercel 提供基础的访问统计，在项目页面的 "Analytics" 中查看。

## 环境变量（如需要）

如果将来需要添加环境变量：
1. 在 Vercel 项目页面，点击 "Settings" → "Environment Variables"
2. 添加变量名和值
3. 重新部署

## 性能优化

Vercel 已自动提供：
- ✅ 全球 CDN 加速
- ✅ 自动 HTTPS
- ✅ 自动压缩
- ✅ 缓存优化

## 成本

- Vercel 免费版完全够用
- 包含：
  - 无限部署
  - 100GB 带宽/月
  - 自定义域名
  - 自动 HTTPS

## 支持

- Vercel 文档：https://vercel.com/docs
- 社区：https://github.com/vercel/vercel/discussions

## 下一步

部署完成后：
1. ✅ 在 App Store Connect 中填写隐私政策 URL
2. ✅ 在 App Store Connect 中填写用户协议 URL
3. ✅ 在 App 中添加网页链接
4. ✅ 测试所有链接是否正常工作
