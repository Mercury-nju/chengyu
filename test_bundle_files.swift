import Foundation

// 测试脚本：检查 Bundle 中的音乐文件
// 在 Xcode 的 Playground 或者添加到项目中运行

func testMusicFiles() {
    print("=== 测试音乐文件加载 ===\n")
    
    let musicFiles = [
        "放松.mp3",
        "清晨.mp3",
        "灵魂.mp3",
        "现代古典.mp3",
        "空灵.mp3",
        "舒缓.mp3",
        "节拍.mp3",
        "轻雨.wav"
    ]
    
    for file in musicFiles {
        if let url = Bundle.main.url(forResource: file, withExtension: nil) {
            print("✅ 找到: \(file)")
            print("   路径: \(url.path)")
        } else {
            print("❌ 找不到: \(file)")
        }
    }
    
    print("\n=== 测试会员音乐文件 ===\n")
    
    let premiumFiles = [
        ("会员音乐", "氛围.mp3"),
        ("会员音乐", "冷静.mp3"),
        ("会员音乐", "宁静.mp3"),
        ("会员音乐", "惬意.mp3"),
        ("会员音乐", "森林.mp3"),
        ("会员音乐", "山谷.mp3"),
        ("会员音乐", "阳光.mp3"),
        ("会员音乐", "治愈.mp3")
    ]
    
    for (subdir, file) in premiumFiles {
        if let url = Bundle.main.url(forResource: file, withExtension: nil, subdirectory: subdir) {
            print("✅ 找到: \(subdir)/\(file)")
            print("   路径: \(url.path)")
        } else {
            print("❌ 找不到: \(subdir)/\(file)")
        }
    }
    
    print("\n=== Bundle 资源路径 ===")
    print("Bundle path: \(Bundle.main.bundlePath)")
    print("Resource path: \(Bundle.main.resourcePath ?? "nil")")
}

// 调用测试
testMusicFiles()
