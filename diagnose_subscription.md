# TestFlight订阅问题诊断

## 问题
TestFlight中显示"找不到产品"，但真机模拟器测试正常。

## 产品ID配置
代码中使用的产品ID：
- ✅ `lumea.plus.monthly`
- ✅ `lumea.plus.annual`
- ✅ `lumea.plus.lifetime`

App Store Connect中配置的产品ID：
- ✅ `lumea.plus.monthly`
- ✅ `lumea.plus.annual`
- ✅ `lumea.plus.lifetime`

产品ID匹配 ✅

## 需要检查的项目

### 1. 产品状态（最可能的原因）

访问：https://appstoreconnect.apple.com
- 我的App → Lumea → 订阅

检查每个产品的状态：

| 产品ID | 期望状态 | 实际状态 |
|--------|---------|---------|
| lumea.plus.monthly | 准备提交 | ？ |
| lumea.plus.annual | 准备提交 | ？ |
| lumea.plus.lifetime | 准备提交 | ？ |

**如果状态不是"准备提交"**：
1. 点击产品
2. 填写所有必填信息：
   - 订阅显示名称
   - 描述
   - 价格
   - 审核信息（如果需要）
3. 点击"保存"

### 2. 订阅组配置

确认订阅组已创建并包含所有产品：
- 订阅组名称：Lumea Plus
- 包含的产品：
  - ✅ Monthly
  - ✅ Annual
  - ✅ Lifetime (非续期订阅)

### 3. App协议状态

访问：https://appstoreconnect.apple.com
- 协议、税务和银行业务

检查：
- ✅ 付费App协议：已生效
- ✅ 银行信息：已填写
- ✅ 税务信息：已填写

如果任何一项显示"需要操作"，必须完成才能使用订阅。

### 4. Bundle ID匹配

确认：
- App Bundle ID：`com.mercury.serenity.us`
- App Store Connect中的App ID：`com.mercury.serenity.us`
- 订阅关联的App：Lumea (com.mercury.serenity.us)

### 5. TestFlight构建版本

确认：
- 使用的是最新上传的构建版本
- 构建版本状态：已完成处理
- 没有使用过期的构建版本

### 6. 沙盒测试账号

TestFlight使用沙盒环境，需要：
1. 创建沙盒测试账号
   - App Store Connect → 用户和访问 → 沙盒技术测试员
2. 在设备上登录沙盒账号
   - 设置 → App Store → 沙盒账号
3. 使用沙盒账号测试购买

## 常见解决方案

### 方案1：等待产品同步（最常见）

如果产品刚创建或修改：
- 等待24-48小时让产品同步到TestFlight
- Apple服务器需要时间同步产品信息

### 方案2：重新保存产品

1. 在App Store Connect中打开每个产品
2. 不做任何修改
3. 点击"保存"
4. 等待几小时后重试

### 方案3：删除并重新创建产品

如果产品配置有问题：
1. 删除现有产品
2. 重新创建产品（使用相同的产品ID）
3. 填写完整信息
4. 保存并等待同步

### 方案4：检查代码中的错误处理

在TestFlight中查看详细错误信息：

```swift
// 在 SubscriptionManager.swift 中添加详细日志
func loadProducts() async {
    do {
        let productIDs = ProductID.allCases.map { $0.rawValue }
        print("🔍 Loading products: \(productIDs)")
        
        products = try await Product.products(for: productIDs)
        print("✅ Loaded \(products.count) products")
        
        if products.isEmpty {
            print("⚠️ No products found!")
        } else {
            for product in products {
                print("📦 Product: \(product.id) - \(product.displayName)")
            }
        }
    } catch {
        print("❌ Error loading products: \(error)")
        print("❌ Error details: \(error.localizedDescription)")
    }
}
```

## 验证步骤

1. **在App Store Connect中验证**
   - 所有产品状态：准备提交 ✅
   - 订阅组已创建 ✅
   - 协议已签署 ✅

2. **在TestFlight中验证**
   - 使用最新构建版本 ✅
   - 登录沙盒测试账号 ✅
   - 查看控制台日志 ✅

3. **在代码中验证**
   - 产品ID正确 ✅
   - 错误处理完善 ✅
   - 日志输出详细 ✅

## 下一步

请检查上述项目，特别是：
1. **产品状态**（最重要）
2. **协议签署状态**
3. **等待时间**（如果刚配置，需要等待同步）

如果所有检查都通过但仍然有问题，可能需要：
- 联系Apple Developer Support
- 提供详细的错误日志
- 检查是否有Apple服务器问题
