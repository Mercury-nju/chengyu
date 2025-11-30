# App Store Connect 内购配置指南

## 1. 创建 App 内购买项目

在 App Store Connect 中，进入你的 App -> 功能 -> App 内购买项目，创建以下三个产品：

### 月度订阅
- **产品 ID**: `com.chengyu.anchor.monthly`
- **类型**: 自动续期订阅
- **订阅群组**: 创建新群组 "澄域 Plus"
- **价格**: ¥12.99/月
- **显示名称**: 澄域 Plus 月度订阅
- **描述**: 解锁所有高级功能，按月订阅

### 年度订阅（推荐）
- **产品 ID**: `com.chengyu.anchor.yearly`
- **类型**: 自动续期订阅
- **订阅群组**: 澄域 Plus（同上）
- **价格**: ¥129.99/年
- **显示名称**: 澄域 Plus 年度订阅
- **描述**: 解锁所有高级功能，按年订阅，相当于每月 ¥10.83

### 永久买断
- **产品 ID**: `com.chengyu.anchor.lifetime`
- **类型**: 非消耗型项目
- **价格**: ¥299
- **显示名称**: 澄域 Plus 永久版
- **描述**: 一次付费，永久解锁所有高级功能

## 2. 配置免费试用

对于月度和年度订阅：
1. 在订阅设置中启用"免费试用"
2. 设置试用期为 7 天
3. 确保"试用优惠"设置为"新订阅者"

## 3. 配置 StoreKit Configuration 文件（用于测试）

在 Xcode 中：
1. File -> New -> File -> StoreKit Configuration File
2. 添加上述三个产品
3. 设置相应的价格和订阅期限
4. 在 Scheme 中选择此配置文件进行本地测试

## 4. 添加 In-App Purchase 能力

1. 在 Xcode 项目中，选择 Target -> Signing & Capabilities
2. 点击 "+ Capability"
3. 添加 "In-App Purchase"

## 5. 配置隐私政策和服务条款

需要在以下位置添加链接：
- App Store Connect 中的 App 信息
- SubscriptionView 中的按钮链接

## 6. 测试

### 沙盒测试
1. 在 App Store Connect -> 用户和访问 -> 沙盒测试员，创建测试账号
2. 在设备上登录沙盒账号（设置 -> App Store -> 沙盒账户）
3. 运行 App 进行购买测试

### 本地测试
1. 使用 StoreKit Configuration 文件
2. 在 Xcode 中运行 App
3. 可以快速测试购买流程，无需真实付款

## 7. 订阅管理

用户可以在以下位置管理订阅：
- iOS 设置 -> Apple ID -> 订阅
- App Store -> 账户 -> 订阅

## 8. 注意事项

- 产品 ID 必须与代码中的完全一致
- 首次提交需要等待苹果审核通过
- 订阅价格一旦设置，修改需要重新审核
- 确保提供清晰的订阅说明和取消方式
- 必须提供恢复购买功能

## 9. 收入分成

- 首年订阅：苹果收取 30%
- 续订（超过一年）：苹果收取 15%
- 小型企业计划：年收入低于 100 万美元，苹果收取 15%
