# 澄域 App 英文本地化计划

## 总体策略

使用编译标志 `US_VERSION` 来区分 CN 和 US 版本，通过 `Localizable.swift` 统一管理所有文本。

---

## 第一批：核心导航和设置（最重要）

**优先级：🔴 最高**

### 1. SettingsView.swift
- 设置页面标题和所有选项
- 预计文本数量：~15 个
- 用户访问频率：高

### 2. ProfileView.swift  
- 个人中心所有菜单项
- 预计文本数量：~10 个
- 用户访问频率：高

### 3. HelpFeedbackView.swift
- 帮助和反馈页面
- FAQ 问题和答案
- 预计文本数量：~20 个
- 用户访问频率：中

### 4. ContentView.swift (Tab Bar)
- 底部导航栏标签
- 预计文本数量：~4 个
- 用户访问频率：最高

**预计时间：30-40 分钟**

---

## 第二批：订阅和会员功能

**优先级：🟠 高**

### 5. SubscriptionView.swift
- 订阅页面所有文案
- 会员权益描述
- 价格和按钮
- 预计文本数量：~25 个
- 重要性：高（涉及收入）

### 6. SubscriptionManager.swift
- 订阅相关提示信息
- 预计文本数量：~5 个

### 7. SphereMaterialPickerView.swift
- 材质选择器
- 预计文本数量：~8 个

**预计时间：20-30 分钟**

---

## 第三批：主要功能页面

**优先级：🟡 中高**

### 8. CalmView.swift
- 主界面（流体光影球页面）
- 稳定值、认知负荷显示
- 预计文本数量：~15 个
- 用户访问频率：最高

### 9. StatusView.swift
- 状态追踪页面
- 图表和统计信息
- 预计文本数量：~12 个

### 10. MyStatsView.swift
- 统计详情页面
- 预计文本数量：~10 个

**预计时间：25-35 分钟**

---

## 第四批：正念练习功能

**优先级：🟡 中**

### 11. TouchAnchorSessionView.swift
- 触感锚点练习
- 预计文本数量：~8 个

### 12. FocusReadSessionView.swift
- 心流铸核（专注阅读）
- 预计文本数量：~10 个

### 13. MindfulRevealSessionView.swift
- 情绪光解
- 预计文本数量：~8 个

### 14. VoiceLogSessionView.swift
- 语音日记
- 预计文本数量：~6 个

**预计时间：20-30 分钟**

---

## 第五批：次要功能页面

**优先级：🟢 中低**

### 15. DailyReminderView.swift
- 每日提醒设置
- 预计文本数量：~10 个

### 16. DeepInsightsView.swift
- 深度洞察页面
- 预计文本数量：~15 个

### 17. HDASettingsView.swift
- 高多巴胺应用设置
- 预计文本数量：~8 个

### 18. RehabView.swift
- 数字戒断页面
- 预计文本数量：~10 个

**预计时间：20-25 分钟**

---

## 第六批：登录和引导

**优先级：🟢 低（可选）**

### 19. LoginView.swift
- 登录页面
- 预计文本数量：~8 个

### 20. OnboardingView.swift
- 新手引导
- 预计文本数量：~12 个

### 21. SplashView.swift
- 启动页
- 预计文本数量：~3 个

**预计时间：15-20 分钟**

---

## 第七批：辅助组件和管理器

**优先级：⚪ 最低**

### 22. StatusManager.swift
- 状态管理器中的提示信息
- 预计文本数量：~5 个

### 23. DeepInsightsManager.swift
- 洞察管理器
- 预计文本数量：~3 个

### 24. 其他小组件
- InfoSheetView.swift
- SubscriptionAlertOverlay.swift
- 预计文本数量：~10 个

**预计时间：10-15 分钟**

---

## 总结

### 文本统计
- **总文件数**：~24 个
- **总文本数量**：~250-300 个
- **预计总时间**：2.5-3 小时

### 分批执行建议

**今天完成：**
- ✅ 第一批（核心导航和设置）
- ✅ 第二批（订阅功能）
- ✅ 第三批（主要功能页面）

**明天完成：**
- 第四批（正念练习）
- 第五批（次要功能）

**可选：**
- 第六批（登录引导）
- 第七批（辅助组件）

---

## 测试计划

### 每批完成后测试：
1. 切换到 US scheme
2. 运行 App
3. 检查修改的页面
4. 确认文本显示正确
5. 确认布局没有问题

### 最终测试：
1. 完整走一遍所有功能
2. 检查是否有遗漏的中文
3. 确认英文表达自然流畅
4. 测试订阅流程
5. 测试所有按钮和交互

---

## 注意事项

### 翻译原则：
1. **自然流畅**：不要直译，要符合英语习惯
2. **简洁明了**：英文通常比中文短，注意布局
3. **一致性**：相同概念使用相同翻译
4. **专业性**：使用正确的行业术语

### 关键术语统一：
- 澄域 → Serenity
- 稳定值 → Stability Score
- 认知负荷指数 → Cognitive Load Index (CLI)
- 触感锚点 → Touch Anchor
- 心流铸核 → Flow Reading
- 情绪光解 → Emotion Release
- 高多巴胺应用 → High Dopamine Apps (HDA)

### 技术要点：
1. 所有文本通过 `L10n.xxx` 访问
2. 使用 `#if US_VERSION` 编译标志
3. 保持代码结构不变
4. 注意字符串插值的处理

---

## 开始执行

准备好了吗？我们从第一批开始！

**第一批文件：**
1. SettingsView.swift
2. ProfileView.swift
3. HelpFeedbackView.swift
4. ContentView.swift (Tab Bar)

确认后我立即开始修改！
