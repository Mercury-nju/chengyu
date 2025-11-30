# 修复循环依赖问题

Extension target 不应该嵌入其他 Extension。需要在 Xcode 中手动移除：

## 快速修复步骤

### 1. 修复 TotalActivityReport-CN

1. 在 Xcode 中选择 **TotalActivityReport-CN** target
2. 切换到 **Build Phases** 标签页
3. 找到 **CopyFiles** 阶段（不是 "Embed ExtensionKit Extensions"）
4. 如果存在，展开它
5. 如果里面有 `TotalActivityReport-US.appex`，点击 **-** 移除
6. 如果整个 CopyFiles 阶段为空，删除整个阶段（点击阶段标题右侧的 **-** 按钮）

### 2. 修复 TotalActivityReport-US

1. 选择 **TotalActivityReport-US** target
2. 切换到 **Build Phases** 标签页
3. 找到 **CopyFiles** 阶段
4. 如果存在，展开它
5. 如果里面有 `TotalActivityReport-CN.appex`，点击 **-** 移除
6. 如果整个 CopyFiles 阶段为空，删除整个阶段

### 3. 验证主应用配置

确保主应用正确嵌入了对应的 Extension：

**锚点 CN:**
- Build Phases → Embed ExtensionKit Extensions
- 应该包含：`TotalActivityReport-CN.appex` ✅
- 不应该包含：`TotalActivityReport-US.appex` ❌

**锚点 US:**
- Build Phases → Embed ExtensionKit Extensions
- 应该包含：`TotalActivityReport-US.appex` ✅
- 不应该包含：`TotalActivityReport-CN.appex` ❌

## 原理说明

**正确的架构：**
```
锚点 CN.app
  └── 嵌入 TotalActivityReport-CN.appex

锚点 US.app
  └── 嵌入 TotalActivityReport-US.appex
```

**错误的架构（当前）：**
```
TotalActivityReport-CN.appex
  └── 复制 TotalActivityReport-US.appex  ❌ 循环依赖

TotalActivityReport-US.appex
  └── 复制 TotalActivityReport-CN.appex  ❌ 循环依赖
```

Extension 是被主应用嵌入的，Extension 之间不应该互相引用。

## 完成后

清理并重新编译：
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*锚点*
xcodebuild -scheme "锚点 CN" clean build
xcodebuild -scheme "锚点 US" clean build
```
