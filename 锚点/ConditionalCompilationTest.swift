import SwiftUI

/// 条件编译测试文件
/// 用于验证 CN_VERSION 和 US_VERSION 编译标志是否正确工作

struct ConditionalCompilationTest {
    
    /// 获取当前版本信息
    static func printVersionInfo() {
        print("=== 条件编译测试 ===")
        
        #if CN_VERSION
        print("✅ 当前版本: 中国版 (CN)")
        print("📱 应用名称: 澄域")
        print("🆔 Bundle ID: com.mercury.chengyu.cn")
        print("📦 App Group: group.com.mercury.chengyu.cn")
        print("🌏 目标市场: 中国大陆")
        #elseif US_VERSION
        print("✅ 当前版本: 美国版 (US)")
        print("📱 应用名称: 澄域")
        print("🆔 Bundle ID: com.mercury.serenity.us")
        print("📦 App Group: group.com.mercury.serenity.us")
        print("🌎 目标市场: 美国")
        #else
        print("⚠️ 警告: 未检测到版本标志!")
        print("请检查 Build Settings 中的 Other Swift Flags 配置")
        #endif
        
        print("==================")
    }
    
    /// 获取版本特定的欢迎消息
    static var welcomeMessage: String {
        #if CN_VERSION
        return "欢迎使用澄域"
        #elseif US_VERSION
        return "Welcome to 澄域"
        #else
        return "Version not configured"
        #endif
    }
    
    /// 获取版本特定的 App Group 标识符
    static var appGroupIdentifier: String {
        #if CN_VERSION
        return "group.com.mercury.chengyu.cn"
        #elseif US_VERSION
        return "group.com.mercury.serenity.us"
        #else
        return "group.undefined"
        #endif
    }
    
    /// 获取版本特定的隐私政策 URL
    static var privacyPolicyURL: String {
        #if CN_VERSION
        return "https://example.com/cn/privacy"
        #elseif US_VERSION
        return "https://example.com/us/privacy"
        #else
        return "https://example.com/privacy"
        #endif
    }
}

// MARK: - 使用示例

extension ConditionalCompilationTest {
    
    /// 在 App 启动时调用此方法进行测试
    static func runTests() {
        printVersionInfo()
        
        print("\n=== 功能测试 ===")
        print("欢迎消息: \(welcomeMessage)")
        print("App Group: \(appGroupIdentifier)")
        print("隐私政策: \(privacyPolicyURL)")
        print("================\n")
    }
}

// MARK: - SwiftUI 测试视图

struct ConditionalCompilationTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("条件编译测试")
                .font(.title)
                .bold()
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(label: "版本", value: versionName)
                InfoRow(label: "应用名称", value: appName)
                InfoRow(label: "Bundle ID", value: bundleID)
                InfoRow(label: "App Group", value: ConditionalCompilationTest.appGroupIdentifier)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Button("打印详细信息") {
                ConditionalCompilationTest.runTests()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    private var versionName: String {
        #if CN_VERSION
        return "中国版 (CN)"
        #elseif US_VERSION
        return "美国版 (US)"
        #else
        return "未配置"
        #endif
    }
    
    private var appName: String {
        #if CN_VERSION
        return "澄域"
        #elseif US_VERSION
        return "Lumea"
        #else
        return "Unknown"
        #endif
    }
    
    private var bundleID: String {
        #if CN_VERSION
        return "com.mercury.chengyu.cn"
        #elseif US_VERSION
        return "com.mercury.serenity.us"
        #else
        return "undefined"
        #endif
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .bold()
        }
    }
}

// MARK: - Preview

#Preview {
    ConditionalCompilationTestView()
}
