# TestFlight问题修复总结

## 修复的问题

### 1. ✅ 付费显示找不到产品
**问题**：TestFlight环境下点击付费显示找不到产品

**原因**：使用了本地StoreKit配置文件的产品ID，但TestFlight需要使用App Store Connect中配置的真实产品ID

**修复**：
- 更新了`SubscriptionManager.swift`中的产品ID
- 为US版本使用正确的产品ID格式：
  - `com.mercury.serenity.us.monthly`
  - `com.mercury.serenity.us.yearly`
  - `com.mercury.serenity.us.lifetime`

**下一步**：
需要在App Store Connect中创建这些产品：
1. 访问：https://appstoreconnect.apple.com
2. 进入"我的App" → "Lumea"
3. 点击"订阅"
4. 创建订阅组和产品

### 2. ✅ 移除Sphere Material设置
**问题**：Settings中的Sphere Material部分需要移除

**修复**：
- 从`SettingsView.swift`中移除了`appearanceSection`
- 移除了Sphere Material选择器的入口

### 3. ✅ 隐私政策和服务条款链接
**问题**：Settings中的隐私政策和服务条款是空白的

**修复**：
- 添加了实际的URL链接：
  - 用户协议：https://lumea-app.vercel.app/terms.html
  - 隐私政策：https://lumea-app.vercel.app/privacy.html
  - 关于Lumea：https://lumea-app.vercel.app

**注意**：确保这些网页已经部署并可访问

### 4. ✅ 背景选择弹窗滑动抽搐
**问题**：选择背景的弹窗向上滑动时会抽搐

**原因**：ScrollView和LazyVGrid的嵌套导致滑动冲突

**修复**：
- 将外层VStack改为LazyVStack
- 优化了ScrollView的配置

## 下一步操作

### A. 在App Store Connect中配置订阅产品

1. **访问App Store Connect**
   ```
   https://appstoreconnect.apple.com
   ```

2. **进入订阅配置**
   - 我的App → Lumea
   - 左侧菜单：订阅

3. **创建订阅组**
   - 点击"+"创建新订阅组
   - 名称：Lumea Plus
   - 参考名称：Lumea Plus Subscription

4. **创建订阅产品**

   **月度订阅**：
   - 产品ID：`com.mercury.serenity.us.monthly`
   - 参考名称：Lumea Plus Monthly
   - 价格：$4.99/月

   **年度订阅**：
   - 产品ID：`com.mercury.serenity.us.yearly`
   - 参考名称：Lumea Plus Yearly
   - 价格：$39.99/年

   **终身订阅**：
   - 产品ID：`com.mercury.serenity.us.lifetime`
   - 类型：非续期订阅
   - 参考名称：Lumea Plus Lifetime
   - 价格：$99.99

### B. 重新构建并上传

1. **Clean Build Folder**
   ```
   Product → Clean Build Folder (⇧⌘K)
   ```

2. **Archive**
   ```
   Product → Archive
   ```

3. **上传到TestFlight**
   - Organizer → Distribute App
   - App Store Connect → Upload

4. **等待处理**
   - 通常需要10-30分钟
   - 处理完成后会收到邮件

5. **测试订阅功能**
   - 在TestFlight中安装新版本
   - 测试订阅购买流程
   - 使用沙盒测试账号

### C. 验证修复

测试以下功能：
- ✅ 订阅购买流程正常
- ✅ Settings中没有Sphere Material选项
- ✅ 隐私政策和服务条款可以打开
- ✅ 背景选择弹窗滑动流畅

## 沙盒测试账号

TestFlight使用沙盒环境测试订阅，需要：

1. **创建沙盒测试账号**
   - 访问：https://appstoreconnect.apple.com
   - 用户和访问 → 沙盒技术测试员
   - 创建新的测试账号

2. **在设备上登录**
   - 设置 → App Store → 沙盒账号
   - 使用测试账号登录

3. **测试订阅**
   - 在TestFlight中打开App
   - 尝试购买订阅
   - 沙盒环境下订阅会立即完成

## 注意事项

1. **订阅产品配置**
   - 必须在App Store Connect中配置产品
   - 产品ID必须完全匹配代码中的ID
   - 产品需要"准备提交"状态才能在TestFlight中测试

2. **网页内容**
   - 确保隐私政策和服务条款页面已部署
   - 内容应该是英文的（US版本）
   - 确保HTTPS可访问

3. **TestFlight限制**
   - 每个构建版本有效期90天
   - 最多10,000个外部测试员
   - 内部测试员最多100个

## 文件修改清单

- ✅ `锚点/SubscriptionManager.swift` - 更新产品ID
- ✅ `锚点/SettingsView.swift` - 移除Sphere Material，添加URL链接
- ✅ `锚点/SphereMaterialPickerView.swift` - 修复滑动问题
