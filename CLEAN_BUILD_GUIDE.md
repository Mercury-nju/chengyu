# 🔧 清理和重新构建指南

## 问题
如果你看到编译错误但代码实际上是正确的，这通常是 Xcode 缓存问题。

## 解决方案

### 方法 1: Xcode 清理（推荐）

1. **清理构建文件夹**
   ```
   在 Xcode 中：
   Product → Clean Build Folder
   或按快捷键：⌘⇧K
   ```

2. **删除派生数据**
   ```
   在 Xcode 中：
   Window → Organizer → Projects
   找到你的项目 → Delete Derived Data
   ```

3. **重新构建**
   ```
   Product → Build
   或按快捷键：⌘B
   ```

### 方法 2: 命令行清理

```bash
# 清理构建文件夹
xcodebuild clean -project 锚点.xcodeproj -scheme 锚点-US

# 删除派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData/

# 重新构建
xcodebuild -project 锚点.xcodeproj -scheme 锚点-US -configuration Debug build
```

### 方法 3: 完全重置

如果上述方法都不行，尝试完全重置：

```bash
# 1. 关闭 Xcode

# 2. 删除所有缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf ~/Library/Caches/com.apple.dt.Xcode/

# 3. 清理项目
xcodebuild clean -project 锚点.xcodeproj -alltargets

# 4. 重新打开 Xcode
open 锚点.xcodeproj
```

## 验证

构建成功后，你应该看到：
- ✅ 0 errors
- ✅ 0 warnings
- ✅ Build Succeeded

## 常见问题

### Q: 清理后还是有错误？
A: 确保你选择了正确的 scheme（锚点-US）

### Q: 编译很慢？
A: 第一次清理后重新构建会比较慢，这是正常的

### Q: 模拟器显示旧版本？
A: 删除模拟器上的 app，重新安装：
```bash
xcrun simctl uninstall booted com.mercury.serenity.us
```

## 当前状态

✅ 所有代码文件已验证无错误
✅ 所有本地化字符串已正确声明
✅ 无重复声明
✅ 准备就绪

如果你看到任何编译错误，请按照上述步骤清理并重新构建。
