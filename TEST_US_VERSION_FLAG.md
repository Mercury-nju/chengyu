# 🧪 测试 US_VERSION 编译标志

## 问题诊断

你的项目配置中已经有 `-D US_VERSION` 标志，但可能没有生效。

## 立即修复步骤

### 1. 完全清理（必须！）

在 Xcode 中：
```
1. Product → Clean Build Folder (⌘⇧K)
2. 关闭 Xcode
3. 删除派生数据：
   rm -rf ~/Library/Developer/Xcode/DerivedData/
4. 重新打开 Xcode
5. 选择 scheme: 锚点 US
6. Product → Build (⌘B)
7. Product → Run (⌘R)
```

### 2. 如果还是中文，检查编译标志

在终端运行：
```bash
xcodebuild -project 锚点.xcodeproj -scheme "锚点 US" -showBuildSettings 2>/dev/null | grep "OTHER_SWIFT_FLAGS"
```

应该看到：
```
OTHER_SWIFT_FLAGS[arch=*] = -D US_VERSION
```

### 3. 添加到 SWIFT_ACTIVE_COMPILATION_CONDITIONS

如果上面的方法还不行，在 Xcode 中：

1. 选择项目 → TARGETS → 锚点 US
2. Build Settings
3. 搜索：`Swift Compiler - Custom Flags`
4. 找到 `Active Compilation Conditions`
5. Debug 行添加：`US_VERSION`
6. Release 行添加：`US_VERSION`

### 4. 验证代码

在 `__App.swift` 或任何文件的 `init()` 中添加：

```swift
init() {
    #if US_VERSION
    print("✅ US_VERSION is ACTIVE")
    #else
    print("❌ US_VERSION is NOT active")
    #endif
    
    print("isUSVersion =", L10n.isUSVersion)
}
```

运行后查看控制台输出。

## 快速测试

创建一个测试文件：

```swift
// Test.swift
import Foundation

struct CompilationTest {
    static func test() {
        #if US_VERSION
        print("🇺🇸 US VERSION ACTIVE")
        #else
        print("🇨🇳 CN VERSION ACTIVE")
        #endif
    }
}
```

在 `__App.swift` 的 `init()` 中调用：
```swift
CompilationTest.test()
```

## 如果还是不行

可能是 Xcode 缓存问题。尝试：

```bash
# 1. 关闭 Xcode

# 2. 删除所有缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf ~/Library/Caches/com.apple.dt.Xcode/

# 3. 清理项目
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US"

# 4. 重新打开并构建
open 锚点.xcodeproj
```

## 最后的办法

如果以上都不行，直接修改 `Localizable.swift`：

```swift
// 临时测试：强制返回 true
static var isUSVersion: Bool {
    return true  // 强制英文
    
    // #if US_VERSION
    // return true
    // #else
    // return false
    // #endif
}
```

这样可以确认是编译标志的问题还是代码的问题。

如果强制返回 true 后显示英文，说明确实是编译标志没生效。
