import SwiftUI
import MessageUI

struct HelpFeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var feedbackText = ""
    @State private var showSubmitAlert = false
    @State private var showMailComposer = false
    @State private var showMailError = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                // Tab Selector
                tabSelector
                
                // Content
                if selectedTab == 0 {
                    helpContent
                } else {
                    feedbackContent
                }
            }
        }
        .sheet(isPresented: $showMailComposer) {
            MailComposeView(
                recipients: ["lihongyangnju@gmail.com"],
                subject: L10n.isUSVersion ? "Lumea App Feedback" : "澄域 App 反馈",
                body: feedbackText,
                onDismiss: { result in
                    if result == .sent {
                        showSubmitAlert = true
                        feedbackText = ""
                    }
                }
            )
        }
        .alert(L10n.thankYou, isPresented: $showSubmitAlert) {
            Button(L10n.isUSVersion ? "OK" : "确定", role: .cancel) { }
        } message: {
            Text(L10n.isUSVersion ? "We've received your feedback. Thank you for helping Lumea improve!" : "我们已收到你的反馈，感谢你帮助澄域变得更好！")
        }
        .alert(L10n.isUSVersion ? "Cannot Send Email" : "无法发送邮件", isPresented: $showMailError) {
            Button(L10n.isUSVersion ? "OK" : "确定", role: .cancel) { }
        } message: {
            Text(L10n.isUSVersion ? "Please configure an email account on your device, or send email to lihongyangnju@gmail.com" : "请在设备上配置邮件账户，或直接发送邮件至 lihongyangnju@gmail.com")
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(L10n.helpTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .frame(height: 60)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            HelpTabButton(title: L10n.faq, isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            HelpTabButton(title: L10n.feedback, isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(height: 50)
    }
    
    var helpContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(faqItems, id: \.question) { item in
                    FAQItem(question: item.question, answer: item.answer)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - FAQ Data
    private var faqItems: [(question: String, answer: String)] {
        if L10n.isUSVersion {
            return [
                (
                    question: "What is Lumea?",
                    answer: "Lumea is a mindfulness app that visualizes your mental state through a fluid sphere. It helps you build focus, reduce digital distraction, and maintain inner peace through daily practices."
                ),
                (
                    question: "How does the fluid sphere work?",
                    answer: "The sphere reflects your mental state in real-time. When you're calm and focused, it moves slowly and smoothly. When stressed or distracted, it becomes chaotic. Your Stability Value and Cognitive Load Index both influence its behavior."
                ),
                (
                    question: "What is Stability Value (SV)?",
                    answer: "SV represents your mental stability (0-100%). It increases through mindfulness practices and decreases from daily stress and digital distractions.\n\nHow to increase:\n• Meditation: +1% per minute (max 30%/day)\n• Touch Anchor: +5%\n• Flow Forging: +8%\n• Emotion Photolysis: +7%\n\nWhat decreases it:\n• Natural daily decay: -15%\n• Distracting app usage: -10% per hour\n\nTip: Practice at least 15 minutes daily to maintain balance."
                ),
                (
                    question: "What is Cognitive Load Index (CLI)?",
                    answer: "CLI measures your brain's stress from digital distractions over the past 24 hours (0-100).\n\n• 0-30: Good focus\n• 30-60: Attention scattered\n• 60-90: High stress\n• 90-100: Severe overload\n\nIt resets every 24 hours. Monitor distracting apps in Settings to track their impact."
                ),
                (
                    question: "What are the mindfulness practices?",
                    answer: "Lumea offers four core practices:\n\n1. Meditation: Guided breathing with ambient music\n2. Touch Anchor: Ground yourself by holding the sphere\n3. Flow Forging: Focused reading to rebuild attention\n4. Emotion Photolysis: Voice journal to release stress\n\nEach practice strengthens different aspects of mental clarity."
                ),
                (
                    question: "What does Lumea Plus include?",
                    answer: "Lumea Plus unlocks:\n• 8 premium meditation soundscapes\n• 10 exclusive sphere materials\n• Deep insights and analytics\n• Advanced focus tracking\n• Priority support\n\nSubscribe monthly ($8.99), annually ($69.99), or lifetime ($129.99)."
                ),
                (
                    question: "How do I track distracting apps?",
                    answer: "Go to Status → Cognitive Load card → Settings icon. Grant Screen Time permission, then add apps to monitor. Lumea will track their usage and show how they affect your mental state."
                ),
                (
                    question: "Can I change the sphere's appearance?",
                    answer: "Yes! Tap the sparkles icon on the Calm page to choose from different materials and themes. Premium materials require Lumea Plus."
                ),
                (
                    question: "Is my data private?",
                    answer: "Absolutely. All your data stays on your device. We don't collect or share your meditation records, stability scores, or app usage data. Sign in with Apple or Google only syncs your subscription status."
                )
            ]
        } else {
            return [
                (
                    question: "如何开始冥想",
                    answer: "进入澄域页面，轻触中央光球即可开始冥想。你可以在开始前选择时长和音乐。"
                ),
                (
                    question: "什么是稳定值",
                    answer: "稳定值代表你的心理稳定程度，是一个持续累积的指标。\n\n增长方式（每日首次）\n• 冥想：1 分钟 = +1%（上限 30%）\n• 触感锚点：+5%\n• 心流铸核：+8%\n• 情绪光解：+7%\n\n损失方式\n• 每日自然衰减：-15%\n• 使用 HDA：每小时 -10%\n\n维持平衡\n• 每天至少需要 +15% 来对抗衰减\n• 建议完成完整流程\n• 完整流程可获得 +20% 以上\n\n视觉反馈\n• 稳定值直接影响光球运动\n• 100% 稳定：缓慢呼吸（速度 0.2x，幅度 0.5x）\n• 0% 稳定：剧烈运动（速度 7.0x，幅度 3.5x）\n• 结合 CLI 决定光球行为"
                ),
                (
                    question: "什么是认知负荷指数",
                    answer: "认知负荷指数反映你的大脑在过去 24 小时内的认知压力水平。\n\n计算方式\n• 基于高多巴胺应用（HDA）的使用时长\n• 使用时间越长，CLI 越高\n• 只统计最近 24 小时的数据\n\n数值含义\n• 0-30：状态良好，注意力集中\n• 30-60：开始分散，建议休息\n• 60-90：高负荷，需要立即休息\n• 90-100：严重透支，必须停止使用\n\n刷新机制\n• 24 小时后自动清零\n• 每天都是新的开始"
                ),
                (
                    question: "如何设置高多巴胺应用监测",
                    answer: "在状态页面点击认知负荷指数卡片上的设置按钮，授权屏幕使用时间访问权限，然后添加需要监测的应用。系统会自动追踪这些应用的使用时长并计算对稳定值的影响。"
                ),
                (
                    question: "四个正念练习分别是什么",
                    answer: "澄域：冥想练习，通过呼吸和音乐进入专注状态\n\n触感锚点：通过触摸光球建立当下连接\n\n心流铸核：专注阅读练习，提升深度思考能力\n\n情绪光解：语音记录情绪，释放内心压力"
                ),
                (
                    question: "如何设置每日提醒",
                    answer: "进入个人信息页面，点击每日提醒，可以设置晨间、午后、傍晚三个预设提醒，也可以添加自定义提醒时间。"
                ),
                (
                    question: "数据会同步吗",
                    answer: "登录账户后，你的稳定值、练习记录等数据会保存在本地。目前暂不支持云端同步，未来版本会添加此功能。"
                )
            ]
        }
    }
    
    var feedbackContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Feedback Text Editor
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.tellUsYourThoughts)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    ZStack(alignment: .topLeading) {
                        if feedbackText.isEmpty {
                            Text(L10n.feedbackPlaceholder)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.top, 12)
                                .padding(.leading, 16)
                        }
                        
                        TextEditor(text: $feedbackText)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .frame(height: 200)
                            .padding(8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                }
                .padding(.horizontal, 20)
                
                // Submit Button
                Button(action: {
                    if !feedbackText.isEmpty {
                        if MFMailComposeViewController.canSendMail() {
                            showMailComposer = true
                        } else {
                            showMailError = true
                        }
                    }
                }) {
                    Text(L10n.submitFeedback)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(feedbackText.isEmpty ? Color.gray.opacity(0.3) : Color.cyan)
                        )
                }
                .disabled(feedbackText.isEmpty)
                .padding(.horizontal, 20)
                
                // Contact Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.cyan)
                        
                        Text(L10n.contactUs)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text(L10n.isUSVersion ? "Email: lihongyangnju@gmail.com" : "邮箱：lihongyangnju@gmail.com")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct HelpTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                
                Rectangle()
                    .fill(isSelected ? Color.cyan : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}


// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String
    let onDismiss: (MFMailComposeResult) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: (MFMailComposeResult) -> Void
        
        init(onDismiss: @escaping (MFMailComposeResult) -> Void) {
            self.onDismiss = onDismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            onDismiss(result)
        }
    }
}
