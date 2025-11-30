# 移除静态 Launch Screen 指南

## 问题
App 启动时会先显示一个静态的 logo 图片，然后才显示光球动效（SplashView）。

## 解决方案

### 方法 1：使用纯黑色 Launch Screen（推荐）

1. **在 Xcode 中打开项目**

2. **选择主 Target**
   - 点击左侧的项目名称（锚点）
   - 选择 TARGETS 下的"锚点"

3. **找到 Info 标签页**
   - 点击顶部的 "Info" 标签

4. **修改 Launch Screen**
   - 找到 "Launch Screen" 或"UILaunchScreen"
   - 如果有 "Launch screen interface file base name"，删除它的值
   - 添加以下配置：

```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string></string>
    <key>UIImageName</key>
    <string></string>
    <key>UILaunchScreen</key>
    <dict>
        <key>UIColorName</key>
        <string>LaunchScreenBackground</string>
    </dict>
</dict>
```

5. **在 Assets.xcassets 中添加颜色**
   - 打开 `锚点/Assets.xcassets`
   - 右键 > New Color Set
   - 命名为 "LaunchScreenBackground"
   - 设置颜色为纯黑色 (R:0, G:0, B:0)

### 方法 2：直接在 Info.plist 中配置

1. **找到 Info.plist 文件**
   - 在项目导航器中找到 Info.plist

2. **添加或修改以下键值**

```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string></string>
    <key>UIImageName</key>
    <string></string>
</dict>
```

### 方法 3：使用空白的 Launch Screen Storyboard

1. **创建新的 Launch Screen**
   - File > New > File
   - 选择 "Launch Screen"
   - 命名为 "LaunchScreen"

2. **设置为纯黑色背景**
   - 打开 LaunchScreen.storyboard
   - 选择 View Controller
   - 在右侧 Attributes Inspector 中
   - 设置 Background 为黑色

3. **不要添加任何 logo 或图片**

4. **在项目设置中指定这个 Launch Screen**
   - 选择 Target > General
   - 在 "App Icons and Launch Screen" 部分
   - Launch Screen File 选择 "LaunchScreen"

## 最简单的方法（iOS 14+）

如果你的 App 只支持 iOS 14 及以上：

1. **删除所有 Launch Screen 文件**
   - 删除 LaunchScreen.storyboard（如果有）

2. **在 Info.plist 中只保留背景色**

```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string></string>
</dict>
```

3. **或者直接删除 UILaunchScreen 键**
   - 这样会使用默认的黑色背景

## 验证

1. **完全删除 App**
   - 从设备上删除旧版本

2. **Clean Build Folder**
   - Product > Clean Build Folder (Shift + Cmd + K)

3. **重新构建并安装**
   - Product > Run (Cmd + R)

4. **测试启动**
   - 完全关闭 App
   - 从主屏幕重新启动
   - 应该直接看到黑色背景，然后是光球动效

## 注意事项

- Launch Screen 是系统级别的，会被缓存
- 必须完全删除 App 并重新安装才能看到效果
- 在模拟器中可能需要重置模拟器
- 真机测试时，可能需要重启设备才能清除缓存

## 如果还是看到 logo

检查以下位置：

1. **Assets.xcassets 中的 AppIcon**
   - 确保没有设置为 Launch Image

2. **项目设置中的 Launch Images Source**
   - Target > General > App Icons and Launch Images
   - Launch Images Source 应该为空或 "Don't use asset catalogs"

3. **Info.plist 中的其他启动相关键**
   - 搜索 "Launch" 相关的键
   - 删除或清空它们的值
