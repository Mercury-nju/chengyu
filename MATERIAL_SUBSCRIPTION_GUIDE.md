# 光球材质订阅功能使用指南

## ✅ 已完成的功能

### 1. 材质分类

#### 免费材质（所有用户可用）
- **默认** (default) - 经典流体光影
- **熔岩核心** (lava) - 炽热的能量涌动
- **寒冰晶格** (ice) - 纯净的冰晶之美
- **鎏金岁月** (gold) - 温暖的金色光辉

#### 会员专属材质（需要订阅）
- **墨玉流体** (ink) - 深邃的东方美学 🔒
- **赛博霓虹** (neon) - 未来感的电子光芒 🔒
- **虚空之境** (void) - 神秘的深空体验 🔒

### 2. 材质选择界面 (SphereMaterialPickerView)

**功能特性：**
- ✅ 实时预览当前选中的材质
- ✅ 清晰区分免费和会员材质
- ✅ 会员材质显示锁定状态和皇冠图标
- ✅ 点击锁定材质自动跳转到订阅页面
- ✅ 选中状态的视觉反馈
- ✅ 流畅的动画效果

**访问路径：**
```
设置 -> 光球材质
```

### 3. 权限检查

在 `SubscriptionManager` 中添加了材质权限检查方法：

```swift
// 检查是否可以使用某个材质
SubscriptionManager.shared.hasAccessToMaterial("ink") // 返回 Bool
```

### 4. 会员状态显示

在个人资料页面的会员卡片中：
- 未订阅：显示"开通会员"按钮
- 已订阅：显示会员类型和到期时间
- 会员卡片有特殊的金色渐变背景

## 🎨 UI 设计特点

### 材质卡片
- 左侧：材质预览圆圈（渐变色）
- 中间：材质名称和描述
- 右侧：选择指示器（圆形单选框）
- 锁定状态：半透明遮罩 + 锁图标

### 预览区域
- 顶部固定预览区域
- 实时显示当前选中材质的流体球效果
- 静态模式（不随触摸移动）

### 视觉反馈
- 选中材质：青色边框 + 青色背景
- 按压效果：轻微缩放动画
- 切换材质：触觉反馈

## 📱 用户流程

### 免费用户选择会员材质
1. 进入设置 -> 光球材质
2. 点击任意会员专属材质（带锁图标）
3. 自动跳转到订阅页面
4. 完成订阅后返回
5. 可以选择所有材质

### 会员用户切换材质
1. 进入设置 -> 光球材质
2. 直接点击任意材质
3. 实时预览效果
4. 选择后自动保存

## 🔧 技术实现

### 材质存储
```swift
// 存储在 StatusManager 中
@AppStorage("sphereMaterial") var sphereMaterial: String = "default"
```

### 材质应用
在 `RehabView` 中：
```swift
var currentMaterial: FluidSphereView.SphereMaterial {
    switch statusManager.sphereMaterial {
    case "lava": return .lava
    case "ice": return .ice
    case "ink": return .ink
    case "gold": return .gold
    case "neon": return .neon
    case "void": return .void
    default: return .default
    }
}
```

### 权限验证
```swift
// 在 SubscriptionManager 中
func hasAccessToMaterial(_ material: String) -> Bool {
    let freeMaterials = ["default", "lava", "ice", "gold"]
    if freeMaterials.contains(material) {
        return true
    }
    return isPremium
}
```

## 🎯 后续可扩展功能

### 1. 更多材质
可以轻松添加新材质：
```swift
// 在 FluidSphereView.SphereMaterial 中添加
case aurora // 极光
case sakura // 樱花
case ocean  // 深海

// 在 SphereMaterialPickerView 中添加到对应列表
```

### 2. 材质解锁动画
- 订阅成功后播放解锁动画
- 材质卡片从锁定到解锁的过渡效果

### 3. 材质收藏
- 允许用户收藏常用材质
- 快速切换收藏的材质

### 4. 材质推荐
- 根据用户的使用习惯推荐材质
- 根据时间段推荐（早晨用冰晶，晚上用墨玉）

### 5. 自定义材质
- 会员可以自定义颜色组合
- 保存个人专属材质配置

## 📊 数据统计

可以添加材质使用统计：
- 最常用的材质
- 每种材质的使用时长
- 材质切换频率

## 🎁 营销策略

### 限时免费体验
```swift
// 可以添加限时免费体验某个会员材质
func isTemporaryFree(_ material: String) -> Bool {
    // 检查是否在活动期间
    return false
}
```

### 新材质上线通知
- 推送通知告知新材质上线
- 在材质列表中显示"新"标签

## 🐛 注意事项

1. **材质切换性能**
   - 材质切换时使用动画过渡
   - 避免频繁切换导致的性能问题

2. **权限同步**
   - 订阅状态变化时自动刷新材质列表
   - 订阅过期后自动切换回免费材质

3. **离线使用**
   - 已选择的材质可以离线使用
   - 权限验证在本地缓存

4. **数据迁移**
   - 如果用户之前选择了会员材质但订阅过期
   - 自动切换回默认材质

## 🔐 安全性

- 材质权限在本地验证
- 订阅状态通过 StoreKit 验证
- 防止越狱设备绕过权限检查（可选）

## 📝 测试清单

- [ ] 免费用户可以选择所有免费材质
- [ ] 免费用户点击会员材质跳转到订阅页面
- [ ] 会员用户可以选择所有材质
- [ ] 材质切换后立即生效
- [ ] 订阅过期后会员材质自动锁定
- [ ] 恢复购买后会员材质自动解锁
- [ ] 材质预览正确显示
- [ ] 选中状态正确显示
- [ ] 动画流畅无卡顿
