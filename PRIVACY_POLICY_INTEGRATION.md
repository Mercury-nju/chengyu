# Privacy Policy & Terms Integration

## ✅ 已完成

App 中的隐私政策和用户协议链接已全部修复并指向正确的网站地址。

## 更新的文件

### 1. LoginView.swift
- ✅ 登录页面底部的"服务条款"和"隐私政策"链接
- 点击后会在 Safari 中打开对应的网页

### 2. SubscriptionView.swift  
- ✅ 订阅页面底部的"Terms of Service"和"Privacy Policy"链接
- 点击后会在 Safari 中打开对应的网页

### 3. SettingsView.swift
- ✅ 设置页面中的"用户协议"和"隐私政策"选项
- 已经正确配置，点击后会在 Safari 中打开对应的网页

## 网站地址

所有链接都指向：
- **用户协议/服务条款**: https://www.chengyu.space/terms.html
- **隐私政策**: https://www.chengyu.space/privacy.html

## 功能说明

当用户点击这些链接时：
1. App 会调用 `UIApplication.shared.open(url)`
2. 系统会在 Safari 浏览器中打开对应的网页
3. 用户可以阅读完整的法律文档
4. 文档包含完整的联系方式和开发者信息

## App Store 审核

这种实现方式完全符合 App Store 审核要求：
- ✅ 用户可以轻松访问隐私政策和用户协议
- ✅ 文档托管在自定义域名上（https://www.chengyu.space）
- ✅ 文档内容完整且符合法律要求
- ✅ 包含开发者联系方式：lihongyangnju@gmail.com

## 测试

在提交审核前，请测试：
1. 在登录页面点击"Terms of Service"和"Privacy Policy"
2. 在订阅页面点击"Terms of Service"和"Privacy Policy"  
3. 在设置页面点击"用户协议"和"隐私政策"
4. 确认所有链接都能正确打开网页：https://www.chengyu.space

## App Store Connect 填写

在提交审核时填写：
- **Support URL**: https://www.chengyu.space
- **Privacy Policy URL**: https://www.chengyu.space/privacy.html
- **Marketing URL** (可选): https://www.chengyu.space
